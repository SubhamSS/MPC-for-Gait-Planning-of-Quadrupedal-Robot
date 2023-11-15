classdef Animate < World
    
    properties(SetAccess=public, GetAccess=public)
        x                       % State data
        GRF                     % Ground Reaction Force Data
        AddLink;                % Additional link sections
        Arm;                    % Arm state data
        Tail;                   % Tail state data
        
        COM;                    % Center of mass
        body;                   % body configuration
        
        sr = 0.014;             % Sphere radius (m)
        cr = 0.012;             % Cylinder radius (m)
    end
    
    properties(SetAccess=private, GetAccess=private)
        numJoints = 0;          % Number of joints to plot
        numLinks = 0;           % Total number of links to plot
        outer;                  % The structure fields of body
        lightSrc;
        
        useSTL = 0;
        pltObj = [];
        grfarrows = [];
    end
    
    methods(Access=public)
        
        function obj = Animate(time, stateData, bodyConfig, cameraView, movieName, varargin)
            % obj = ANIMATE(time, stateData, bodyConfig, cameraView, movieName, varargin)
            %
            % Inputs:
            %   time - the time vector (1xn vector)
            %   stateData - the matrix with all the robot configuration
            %               data (6xn matrix)
            %   bodyConfig - a structure containing information about the
            %                configuration of the robot
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
            %   'Options' - AnimOptions object. This object contains
            %               settings to be used by the animator. All
            %               options can be set here and passed in at once,
            %               or the settings can be passed in as name-value
            %               pairs. See AnimOptions() for details.
            %
            % NOTE: StepType will always be set to 'time' when recording,
            %       as this makes for a higher quality video.
            %
            % See also AnimOptions
            %
            
            if nargin<3
                error('Time data, state data, and the body configuration are required inputs');
            elseif nargin==3
                cameraView = 'iso';
                movieName = '';
            elseif nargin==4
                movieName = '';
            end
            
            if length(time)~=size(stateData,2)
                error('Length of time vector must match the number of columns of the state data');
            end
            
            if any(any(isnan(stateData)))
                error('State data contains NaN values. Cannot animate with NaN values');
            end
            
            obj = obj@World(time, cameraView, movieName);
            
            if ~isfield(bodyConfig,'COM')
                error('Animate: bodyConfig input MUST contain COM field');
            end
            
            % ========================================== %
            % Parse name-value pairs
            % ========================================== %
            opts = AnimOptions(varargin{:});
            fieldNames = fields(opts);
            for n=1:length(fieldNames)
                obj.(fieldNames{n}) = opts.(fieldNames{n});
            end
            
            % ========================================== %
            % Set body configuration
            % ========================================== %
            outer = fields(bodyConfig);
            ind = find(strcmp(outer,'COM')==0,1,'first');
            current = bodyConfig.(outer{ind});
            while (isstruct(current))
                next = fields(current);
                if any(strcmp(next,'stl'))
                    obj.useSTL = 1;
                    break
                end
                current = current.(next{1});
            end
            
            % ========================================== %
            % Initialize reference line on linked figures
            % ========================================== %
            if ~isempty(obj.LinkFig)
                for i = 1:length(obj.LinkFig)
                    for j = 1:length(obj.LinkFig(i).Children)
                        ax = obj.LinkFig(i).Children(j);
                        if isa(ax,'matlab.graphics.axis.Axes')
                            hold(ax,'on');
                            ax.XLimMode = 'manual';
                            ax.YLimMode = 'manual';
%                             xline(ax,0,'--k','linewidth',2,'displayname','CurrTime');
                            plot(ax,[0,0],[-5000,5000],'--k','linewidth',2,'displayname','CurrTime');
                            hold(ax,'off');
                        end
                    end
                end
            end
            
            % ========================================== %
            % Initialize Animation
            % ========================================== %
            if obj.useSTL
                obj.pltObj = AnimateSTL(stateData,bodyConfig,obj.ax);
            else
                obj.pltObj = AnimateNoSTL(stateData,bodyConfig,obj.AddLink,obj.ax);
            end
            
            axis(obj.ax,[obj.Center(1)-obj.Delta obj.Center(1)+obj.Delta obj.Center(2)-obj.Delta obj.Center(2)+obj.Delta -0.1 -0.1+obj.Delta]);
            daspect(obj.ax,[1,1,1]);
            
            % ========================================== %
            % Initialize GRF arrows
            % ========================================== %
            if ~isempty(obj.GRF)
                plotParams = {'FaceColor',       [0.2,0.2,0.6], ...
                              'EdgeColor',       'none',        ...
                              'AmbientStrength', 1, ...
                              'DiffuseStrength', 0.4,...
                              'SpecularStrength',0.5};
                
                [X1,Y1,Z1] = cylinder(0.01,10); 
                [X2,Y2,Z2] = cylinder([0.02,0],10);
                X = [X1;X2];
                Y = [Y1;Y2];
                Z = [2/6*Z1;1/14*Z2+2/6];
                hold(obj.ax,'on');
                for n = 1:4
                    s = surf(obj.ax,X,Y,Z,plotParams{:});
                    obj.grfarrows(n) = hgtransform('Parent',obj.ax);
                    set(s,'Parent',obj.grfarrows(n));
                    set(obj.grfarrows(n),'UserData',s.ZData);
                end
                hold(obj.ax,'off');
            end
            
            % ========================================== %
            % AutoPlay/Start making movie
            % ========================================== %
            BeginAutoPlay(obj);
        end
        
    end
    
    methods(Access=public)
        
        function UpdatePlotData(obj)
            obj.Center = obj.pltObj.UpdatePlotData();
            obj.GRF_arrow
        end
        
        function GRF_arrow(obj)
            if ~isempty(obj.GRF)
                ind = obj.ax.UserData;
                ssc = @(v) [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
                RU = @(A,B) eye(3) + ssc(cross(A,B)) + ssc(cross(A,B))^2*(1-dot(A,B))/(norm(cross(A,B))^2);
                T = eye(4);
                for n = 1:4
                    f = obj.GRF(ind,3*(n-1)+1:3*n);
                    p = obj.GRF(ind,3*(n-1)+13:3*n+12);
                    mag = norm(f);
                    z = get(obj.grfarrows(n),'UserData');
                    s = get(obj.grfarrows(n),'Children');
                    if mag<1e-4
                        s.FaceAlpha = 0;
                        continue;
                    else
                        s.FaceAlpha = 1;
                    end
                    s.ZData = z*mag/80;
                    if all(f'/mag == [0;0;1])
                        T(1:3,1:3) = eye(3);
                    else
                        T(1:3,1:3) = RU([0;0;1],f/mag);
                    end
                    T(1:3,end) = p';
                    set(obj.grfarrows(n),'Matrix',T);
                end
            end
        end
        
    end
    
end