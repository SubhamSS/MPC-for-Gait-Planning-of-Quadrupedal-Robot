classdef World < handle
    
    properties(SetAccess=public, GetAccess=public)
        FrameInc;               % Number of frames to increment by during animation
        Delta;                  % Width and length (m) for the plot from the COM
        SliderStep;             % ~Time step size for the slider (sec)
        StepType;               % Time or frame. I.e., use constant time step, or constant frame step
        AutoPlay;
        
        AnimView;               % The view of the animation (iso, side, top, back)
        TimeIndex = 1;          % The current time index of the animation
        OutputName;             % The name of the movie to be output (if saving)
        
        UpdateCallback = [];    % Name of the plot update function to use (not required if a subclass has the method 'UpdatePlotData' defined)
        
        fig;                    % Figure handle
        
        LinkFig;
    end
    
    properties(SetAccess=protected, GetAccess=public)
        Time;                   % The time vector
        ax;                     % Axes handle
        
        Button;                 % Button handle
        Slider;                 % Slider handle
        Dummy;                  % Dummy button handle
        AnimTime;               % Current time point that is to be plotted if stepping by time
        FrameRate = 30;         % Record frame rate (frames per second)
        
        Center = [0;0;0];       % Where should the plot be centered ([x;y;z])
        terrain;                % Handle to the terrain plot
        
        playPanel;
        viewPanel;
        
        Playing;
    end
    
    methods(Access=protected)
        
        function obj = World(time, cameraView, movieName, varargin)
            % Inputs:
            %   time - the time vector
            %   cameraView - the camera view ('iso','side','back','top'),
            %               or the azmuth and elevation (view=[az,el])
            %               default: 'iso'
            %   movieName - the name of the movie to make (if empty, no
            %               recording will occur), default: ''
            %
            % Name-Value pair inputs (optional):
            %   'SliderStep' - the time step size for the slider
            %                  (default=0.01 seconds)
            %   'FrameInc' - the number of frames to increment by during
            %                the animation (default=30 frames)
            %   'StepType' - Step animation based on time or frames?
            %                ('time','frame'), default='frame'
            %                Ex) increment the animation by 30 frames, or
            %                    increment the animation by 1/30th of a second? 
            %   'AutoPlay' - Start Animation automatically, default=true
            %   'Delta' - the x-y bounds on plotting from the COM,
            %             default=0.6(m)
            %   'LinkFig' - Array of figure handles that have the simulation time
            %               on the x axis. The animator will move a vertical line
            %               across the plot that indicates the current animation
            %               time.
            %
            % NOTE: StepType will always be set to 'time' when recording,
            %       as this makes for a higher quality video.
            % 
            % See also AnimOptions
            
            if nargin<1
                error('Time data, state data, and the body configuration are required inputs');
            elseif nargin==1
                cameraView = 'iso';
                movieName = '';
            elseif nargin==2
                movieName = '';
            end
            
            obj.Time = time;
            obj.OutputName = movieName;
            obj.AnimTime = time(1);
            obj.Playing = 0;
            
            % ========================================== %
            % Parse name-value pairs
            % ========================================== %
            p = inputParser;
            addParameter(p,'SliderStep', 0.01,@(x) isnumeric(x) && isscalar(x) && (x>0) );
            addParameter(p,'FrameInc', 30, @(x) isnumeric(x) && isscalar (x) && floor(x)==x && (x>0));
            addParameter(p,'Delta', 0.6, @(x) isnumeric(x) && isscalar(x) && (x>0));
            addParameter(p,'StepType','frame',@(x)ischar(x)&&any(strcmpi(x,{'frame','time'})));
            addParameter(p,'AutoPlay',1,@(x) x==1 || x==0 ||  islogical(x));
            addParameter(p,'LinkFig',[],@(x) all(ishandle(x)));
            parse(p,varargin{:});
            
            fieldNames = fields(p.Results);
            for n = 1:length(fieldNames)
                obj.(fieldNames{n}) = p.Results.(fieldNames{n});
            end
            
            % ========================================== %
            % Plot terrain and setup figure
            % ========================================== %
            obj.fig = figure(4096);
%             obj.fig.HandleVisibility = 'on';
            obj.fig.Name = 'Quad_Anim';
            obj.fig.Units = 'Pixels';
            obj.fig.Position = [50 100 1000 600];
            if isempty(obj.fig.Children)
                obj.ax = axes(obj.fig);
            else
                obj.ax = obj.fig.Children(end);

            end
%             obj.fig.HandleVisibility = 'off';
            obj.ax.UserData = 1;
            [terrain.Tx, terrain.Ty] = meshgrid(-10:10:30, -20:10:20);
            terrain.Tz = 0.*terrain.Tx;
            ground = ColoredChecker(80,20,'g');
            obj.terrain = surface(obj.ax,terrain.Tx,terrain.Ty,terrain.Tz,...
                'FaceColor','texturemap',...
                'CData',ground,...
                'EdgeColor','none');
            
            obj.UpdateView(cameraView);
            axis(obj.ax,[-obj.Delta, obj.Delta, -obj.Delta, obj.Delta, -0.01, -0.1+obj.Delta]);
            title(obj.ax,sprintf('Time = %6.3f (s)', obj.Time(obj.TimeIndex)));
            xlabel(obj.ax,'x (m)');
            ylabel(obj.ax,'y (m)');
            zlabel(obj.ax,'z (m)');
            drawnow;
            
            % ========================================== %
            % Initialize reference line on linked figures
            % ========================================== %
            if ~isempty(obj.LinkFig)
                for i = 1:length(obj.LinkFig)
                    for j = 1:length(obj.LinkFig(i).Children)
                        ax = obj.LinkFig(i).Children(j);
                        if isa(ax,'matlab.graphics.axis.Axes')
                            hold(ax,'on');
                            xline(ax,0,'--k','linewidth',2,'displayname','current_time');
                            hold(ax,'off');
                        end
                    end
                end
            end
            
            % ========================================== %
            % Start the UI controls
            % ========================================== %
            vis = 1;
            if(~isempty(movieName)); vis = 0; end
            p = uipanel(obj.fig,'Units','pixels','Position',[0 0 205 50]);
            p.BorderType = 'none';
            p.Visible = vis;
            s = uicontrol(p,'Style','slider');
            s.Position = [0,0,205,25];
            s.Max = obj.Time(end);
            s.Value = obj.Time(1);
            s.Min = obj.Time(1);
            s.SliderStep = [1,1]*obj.SliderStep/(obj.Time(end)-obj.Time(1));
            s.Callback = @obj.SliderCallback;
            obj.Slider = s;
            
            b = uicontrol(p,'Style','pushbutton');
            b.Position = [0,25,80,25];
            b.String = 'Play';
            b.Callback = @obj.PlayButtonCallback;
            b.UserData = 1;
            obj.Button = b;
            obj.playPanel = p;
            
            % Make view panel and buttons
            p = uipanel(obj.fig,'Position',[0 0.9550 0.3 0.04]);
            p.BorderType = 'none';
            p.Visible = vis;
            uicontrol(p,'Style','pushbutton','Position',[5,5,45,20],'String','iso','Callback',@obj.ToggleView);
            uicontrol(p,'Style','pushbutton','Position',[55,5,45,20],'String','side','Callback',@obj.ToggleView);
            uicontrol(p,'Style','pushbutton','Position',[105,5,45,20],'String','front','Callback',@obj.ToggleView);
            uicontrol(p,'Style','pushbutton','Position',[155,5,45,20],'String','top','Callback',@obj.ToggleView);
            obj.viewPanel = p;
            
            obj.Dummy = uicontrol(obj.fig,'Style','pushbutton','Position',[0,0,1,1],'Callback',@obj.DummyCallback);
            
            set(obj.fig,'WindowKeyPressFcn',@obj.KeyPressCallback);
        end
        
    end
    
    methods(Access=private)
       
        function ToggleView(obj,src,~)
            cameraView = src.String;
            v = obj.UpdateView(cameraView);
            [az,el] = view();
            vcurr = [az,el];
            if all(v==vcurr) && ~any(strcmp(cameraView,{'top','iso'}))
                v(1) = v(1)-180;
            elseif all(v==vcurr) && strcmp(cameraView,'iso')
                v(1) = v(1)-90;
            end
            view(obj.ax,v);
        end
        
        function ToggleViewKey(obj,cameraView)
            v = obj.UpdateView(cameraView);
            [az,el] = view(obj.ax);
            vcurr = [az,el];
            if all(v==vcurr) && ~any(strcmp(cameraView,{'top','iso'}))
                v(1) = v(1)-180;
            elseif all(v==vcurr) && strcmp(cameraView,'iso')
                v(1) = v(1)-90;
            end
            view(obj.ax,v);
        end
        
        function DummyCallback(~,~,~)
        end
        
    end
    
    methods(Access=public)
        
        function delete(obj)
            if obj.Playing
                obj.Button.UserData = 0;
                pause(0.1);
            end
            if ishandle(obj.fig)
                delete(obj.fig);
            end
        end
            
        function UpdateAnim(obj)
            UpdatePlotData(obj); % Assumed to be a subclass method or a callback has been specified
            str = sprintf('Time = %3.3f (s)', obj.Time(obj.TimeIndex));
            obj.ax.Title.String = str;
            axis(obj.ax,[obj.Center(1)-obj.Delta, obj.Center(1)+obj.Delta, obj.Center(2)-obj.Delta, obj.Center(2)+obj.Delta, -0.01, -0.1+obj.Delta]);
            obj.Slider.Value = obj.Time(obj.TimeIndex);
            drawnow limitrate
            
            for i = 1:length(obj.LinkFig)
                if ishandle(obj.LinkFig(i))
                    for j = 1:length(obj.LinkFig(i).Children)
                        tmpax = obj.LinkFig(i).Children(j);
                        if isa(tmpax,'matlab.graphics.axis.Axes')
                            for k = 1:length(tmpax.Children)
                                if strcmp(tmpax.Children(k).DisplayName,'CurrTime')
                                    set(tmpax.Children(k),'XData',[obj.Time(obj.TimeIndex),obj.Time(obj.TimeIndex)]);
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        function Play(obj,mov)
            if nargin == 1
                mov = [];
            end
            L = length(obj.Time);
            obj.Button.String = 'Pause';
            obj.Playing = 1;
            while (obj.TimeIndex<=L && ishandle(obj.fig) && obj.Button.UserData==1)
                UpdateAnim(obj); 
                if strcmpi(obj.StepType,'frame')
                    obj.TimeIndex = obj.TimeIndex+obj.FrameInc;
                else
                    % If incrementing by a constant time step, find the
                    % nearest data point to the desired time
                    obj.AnimTime = obj.AnimTime+1/obj.FrameRate;
                    obj.TimeIndex = interp1(obj.Time,1:length(obj.Time),obj.AnimTime,'nearest');
                end
                if ~isempty(mov) && mov~=-1 && ishandle(obj.fig)
                    f = getframe(obj.fig);
                    writeVideo(mov,f);
                end
            end
            obj.Playing = 0;
            
            % Makes sure that the last frame is always played
            if ishandle(obj.fig) && obj.Button.UserData==1
                obj.TimeIndex = L;
                obj.AnimTime = obj.Time(end);
                UpdateAnim(obj);
                drawnow;
                if ~isempty(mov) && mov~=-1
                    f = getframe(obj.fig);
                    writeVideo(mov,f);
                end
            end
            
            % Makes sure that the button settings/string is restored
            if ishandle(obj.fig)
                obj.playPanel.Visible = 1;
                obj.viewPanel.Visible = 1;
                obj.Button.String = 'Play';
                obj.Button.UserData = 1;
            end
            
            % If played until the end, clicking play again will start from
            % the beginning
            if ishandle(obj.fig) && obj.TimeIndex==L
                obj.TimeIndex = 1;
                obj.AnimTime = obj.Time(1);
            end
        end
        
        function BeginAutoPlay(obj)
            UpdateAnim(obj);
            if ~isempty(obj.OutputName)
                % If there is an output name, start recording and suppress
                % the UI controls until recording is over. In addition,
                % temporarily change the StepType to 'time' for to obtain a
                % constant frame rate.
                tempType = obj.StepType;
                obj.StepType = 'time';
                mov = VideoWriter(obj.OutputName);
                open(mov);
                obj.playPanel.Visible = 0;
                obj.viewPanel.Visible = 0;
                obj.TimeIndex = 1;
                UpdateAnim(obj);
                obj.Play(mov);
                close(mov);
                UpdateAnim(obj);
                obj.StepType = tempType;
            elseif obj.AutoPlay
                % If AutoPlay is enabled (default=true), then start the
                % animation
                obj.Play;
            end
        end
        
        function UpdatePlotData(obj)
            if isempty(obj.UpdateCallback)
                warning('No subclass method ''UpdatePlotData'' found and ''UpdateCallback'' is empty');
            else
                obj.UpdateCallback(obj);
            end
        end
        
        function SliderCallback(obj,src,~)
            obj.TimeIndex = find(obj.Time>=src.Value,1,'first');
            obj.AnimTime = src.Value;
            src.Value = obj.Time(obj.TimeIndex);
            UpdateAnim(obj);
            
            % The following makes it so that, if the slider is put at the
            % end, clicking play will start the animation from the
            % beginning again
            if obj.TimeIndex==length(obj.Time)
                obj.TimeIndex = 1;
            end
        end
        
        function PlayButtonCallback(obj,src,~)
            if strcmp(src.String,'Play')
                obj.Play;
            else
                src.UserData = 0;
            end
        end
        
        function KeyPressCallback(obj,~,evt)
            if strcmpi(evt.Key,'return')
                uicontrol(obj.Dummy);
                drawnow;
                obj.PlayButtonCallback(obj.Button,evt);
            elseif strcmpi(evt.Key,'space')
                curr = gco(obj.fig);
                if isa(curr,'matlab.ui.control.UIControl') && any(strcmp(curr.String,{'iso','side','front','top'}))
                    ToggleView(obj,curr);
                end
                uicontrol(obj.Dummy);
                drawnow;
                obj.PlayButtonCallback(obj.Button,evt);
            elseif strcmpi(evt.Key,'rightarrow')
                if obj.Slider.Value+obj.SliderStep<=obj.Slider.Max
                    obj.Slider.Value = obj.Slider.Value + obj.SliderStep;
                    obj.SliderCallback(obj.Slider,evt);
                end
            elseif strcmpi(evt.Key,'leftarrow')
                if obj.Slider.Value-obj.SliderStep>=obj.Slider.Min
                    obj.Slider.Value = obj.Slider.Value - obj.SliderStep;
                    obj.SliderCallback(obj.Slider,evt);
                end
            elseif strcmpi(evt.Key,'escape')
                if obj.Playing
                    obj.PlayButtonCallback(obj.Button,evt);
                end
                obj.fig.WindowState = 'Minimize';
            elseif strcmp(evt.Key,'s')
                obj.ToggleViewKey('side');
            elseif strcmp(evt.Key,'i')
                obj.ToggleViewKey('iso');
            elseif strcmp(evt.Key,'t')
                obj.ToggleViewKey('top');
            elseif strcmp(evt.Key,'f')
                obj.ToggleViewKey('front');
            end
        end
        
        function IncFrame(obj,inc)
            % NOT FULLY TESTED. There are known issues.
            if 0<(obj.TimeIndex+inc) && (obj.TimeIndex+inc)<length(obj.Time)
                obj.TimeIndex = obj.TimeIndex+inc;
            end
            obj.AnimTime = obj.Time(obj.TimeIndex);
            UpdateAnim(obj);
            
            if obj.TimeIndex==length(obj.Time)
                obj.TimeIndex = 1;
            end
        end
       
        function varargout = UpdateView(obj,cameraView)
            if ischar(cameraView)
                switch cameraView
                    case 'side'
                        v = [180 5];
                    case 'front'
                        v=[90 5];
                    case 'iso'
                        v=[230 20];
                    case'top'
                        v=[270 90];
                    otherwise
                        v=[230 20];
                end
            elseif isnumeric(cameraView) && length(cameraView)==2
                v = cameraView;
            elseif isempty(cameraView)
                [az,el] = view(obj.ax);
                v = [az,el];
            else
                fprintf(2,'Invalid camera view provided\n');
                [az,el] = view(obj.ax);
                varargout{1} = [az,el];
                return;
            end
            if nargout == 0
                view(obj.ax,v);
            else
                varargout{1} = v;
            end
            
        end
        
    end
    
    methods % Set Methods
        
        function set.SliderStep(obj,new)
            obj.SliderStep = new;
            obj.Slider.SliderStep = [1,1]*new/(obj.Time(end)-obj.Time(1)); %#ok<*MCSUP>
        end
        
        function set.UpdateCallback(obj,str)
            if ischar(str) && str(1)~='@'
                fun = str2func(['@(x)',str,'(x)']);
                obj.UpdateCallback = fun;
            elseif ischar(str)
                obj.UpdateCallback = str;
            else
                error('Invalid function');
            end
        end
        
        function set.TimeIndex(obj,new)
            obj.TimeIndex = new;
            obj.ax.UserData = new; 
        end
        
        function set.Time(obj,new)
            obj.Time = new;
            if ~isempty(obj.Slider)
                obj.Slider.Min = new(1);   
                obj.Slider.Max = new(end);
                if obj.Slider.Value < obj.Slider.Min
                    obj.Slider.Value = obj.Slider.Min;
                elseif obj.Slider.Value > obj.Slider.Max
                    obj.Slider.Value = obj.Slider.Max;
                end
            end
        end
    end
    
end

