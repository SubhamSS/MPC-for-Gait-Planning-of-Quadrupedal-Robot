classdef AnimOptions
    % This class creates a structure of the default settings for the
    % animator. The settings can be changed and then passed into the
    % animator as opposed to passing in all settings as a name value pair.
    %
    %
    % Constructor:
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
    %   'GRF' - Array of GRFs and their location (24 x n). The GRF 
    %           should be the first 12 columns, and the location of
    %           the GRF should be the last 12 columns. 
    %
    
    properties
        SliderStep = 0.01;
        FrameInc = 30;
        StepType = 'Time';
        AutoPlay = true;
        Delta = 0.6;
        LinkFig = [];
        AddLink = {};
        GRF = [];
    end
    
    methods
        function obj = AnimOptions(varargin)
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
            %   'GRF' - Array of GRFs and their location (24 x n). The GRF 
            %           should be the first 12 columns, and the location of
            %           the GRF should be the last 12 columns. 
            %
            
            p = inputParser;
            addParameter(p,'AddLink',{},@(x)iscell(x));
            addParameter(p,'SliderStep', 0.01,@(x) isnumeric(x) && isscalar(x) && (x>0) );
            addParameter(p,'FrameInc', 30, @(x) isnumeric(x) && isscalar (x) && floor(x)==x && (x>0));
            addParameter(p,'Delta', 0.6, @(x) isnumeric(x) && isscalar(x) && (x>0));
            addParameter(p,'StepType','frame',@(x)ischar(x)&&any(strcmpi(x,{'frame','time'})));
            addParameter(p,'AutoPlay',1,@(x) x==1 || x==0 ||  islogical(x));
            addParameter(p,'LinkFig',[],@(x) all(ishandle(x)));
            addParameter(p,'Options',[],@(x) isa(x,'AnimOptions'));
            addParameter(p,'GRF',[],@(x) size(x,2)==24 || isempty(x));
            parse(p,varargin{:});

            fieldNames = fields(p.Results);
            if ~isempty(p.Results.Options)
                for n=1:length(fieldNames)
                    if strcmp(fieldNames{n},'Options')~=1
                        obj.(fieldNames{n}) = p.Results.Options.(fieldNames{n});
                    end
                end
            end
            for n = 1:length(fieldNames)
                if ~any(strcmp(fieldNames{n},p.UsingDefaults)==1) && strcmp(fieldNames{n},'Options')~=1
                    obj.(fieldNames{n}) = p.Results.(fieldNames{n});
                end
            end
            
        end
    end
end

