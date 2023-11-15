classdef AnimateSTL < handle
    
    properties(SetAccess=public, GetAccess=public)
        x;                      % The robot positions
        Arm;                    % Arm state data
        Tail;                   % Tail state data
        
        COM;                    % Center of mass
        body;                   % body configuration
    end
    
    properties(SetAccess=private, GetAccess=private)
        outer;
        lightSrc;
        
        ax;
    end
    
    methods
        
        function obj = AnimateSTL(stateData, bodyConfig, ax)
            % Inputs:
            %   time - the time vector
            %   stateData - the matrix with all the robot configuration
            %               data (18xn matrix)
            %   bodyConfig - a structure containing information about the
            %                configuration of the robot
            % 
            
            if nargin<3
                error('Time data, state data, and the body configuration are required inputs');
            end
            
            if ~isfield(bodyConfig,'COM')
                error('bodyConfig input MUST contain COM field');
            end
            obj.ax = ax;
            obj.COM = bodyConfig.COM;
            bodyConfig = rmfield(bodyConfig,'COM');
            obj.body = bodyConfig;
            obj.outer = fields(obj.body);
            obj.x = stateData;
            
            % ========================================== %
            % Plot the links for first time
            % ========================================== %
            axes(obj.ax);
            hold(obj.ax, 'on');
%             CL = camlight('headlight');
            obj.lightSrc    = light(obj.ax,'Position',[ 1.5,0,1.5],'Style','local');
            obj.lightSrc(2) = light(obj.ax,'Position',[-1.5,0,1.5],'Style','local');
            obj.lightSrc(3) = light(obj.ax,'Position',[0, 1.5,1.5],'Style','local');
            obj.lightSrc(4) = light(obj.ax,'Position',[0,-1.5,1.5],'Style','local');
            
            lightangle(obj.lightSrc(1),  90, 25);
            lightangle(obj.lightSrc(2), -90, 25);
            lightangle(obj.lightSrc(3),   0, 25);
            lightangle(obj.lightSrc(4), 180, 25);
            
            material(obj.ax.Children(end),'dull');
            obj.ax.Children(end).AmbientStrength=0.8;
            plotParams = {'FaceColor',       [0.8 0.8 0.8], ...
                          'EdgeColor',       'none',        ...
                          'FaceLighting',    'gouraud',     ...
                          'AmbientStrength', 0.1, ...
                          'DiffuseStrength', 0.2,...
                          'SpecularStrength',0.2};
                      
            obj.outer = fields(obj.body);
            for n = 1:length(obj.outer)
                inner = fields(obj.body.(obj.outer{n}));
                if any(strcmp(inner,'function'))
                    p = patch(obj.ax,obj.body.(obj.outer{n}).stl,plotParams{:});
                    obj.body.(obj.outer{n}).hgt = hgtransform('Parent',obj.ax);
                    set(p,'Parent',obj.body.(obj.outer{n}).hgt);
                    obj.body.(obj.outer{n}).T = obj.body.(obj.outer{n}).function(obj.x(:,1));
                    set(obj.body.(obj.outer{n}).hgt,'Matrix',obj.body.(obj.outer{n}).T);
                else
                    for k = 1:length(inner)
                        p = patch(obj.ax,obj.body.(obj.outer{n}).(inner{k}).stl,plotParams{:});
                        obj.body.(obj.outer{n}).(inner{k}).hgt = hgtransform('Parent',obj.ax);
                        set(p,'Parent',obj.body.(obj.outer{n}).(inner{k}).hgt);
                        obj.body.(obj.outer{n}).(inner{k}).T = obj.body.(obj.outer{n}).(inner{k}).function(obj.x(:,1));
                        set(obj.body.(obj.outer{n}).(inner{k}).hgt,'Matrix',obj.body.(obj.outer{n}).(inner{k}).T);
                    end
                end
            end
            daspect(obj.ax,[1,1,1]);
            hold(obj.ax, 'off');
        end
        
        function COM = UpdatePlotData(obj)
            ind = obj.ax.UserData;
            current_x = obj.x(:,ind);
            COM = obj.COM.function(current_x);
            for n = 1:length(obj.outer)
                inner = fields(obj.body.(obj.outer{n}));
                if any(strcmp(inner,'function'))
                    obj.body.(obj.outer{n}).T = obj.body.(obj.outer{n}).function(current_x);
                    set(obj.body.(obj.outer{n}).hgt,'Matrix',obj.body.(obj.outer{n}).T);
                else
                    for k = 1:length(inner)
                        obj.body.(obj.outer{n}).(inner{k}).T = obj.body.(obj.outer{n}).(inner{k}).function(current_x);
                        set(obj.body.(obj.outer{n}).(inner{k}).hgt,'Matrix',obj.body.(obj.outer{n}).(inner{k}).T);
                    end
                end
            end
        end
        
    end
end