function [robot_obj] = AnimateA1_SRB(time, stateData, cameraView, movieName, varargin)
    % [robot_obj] = AnimateA1(time, stateData, loadSTL, cameraView, movieName, varargin)
    %
    % This function will begin the animation for the A1 robot using the
    % parameters and data passed in.
    %
    % Inputs:
    %   time - the time vector
    %   stateData - the matrix with all the robot configuration
    %               data (6xn matrix)
    %   cameraView - the camera view ('iso','side','back','top'),
    %               default: 'iso'
    %   movieName - the name of the movie to make (if empty, no
    %               recording will occur), default: ''
    %
    % Name-Value pair inputs (optional):
    %   'Options' - pass in an options structure. Create with AnimOptions()
    %               function
    %
    % see also AnimOptions
    %
    
    if nargin<3
        error('Time data and state data are required inputs');
    elseif nargin==3
        cameraView = 'iso';
        movieName = '';
    elseif nargin==4
        movieName = '';
    end
    
    % ========================================== %
    % Get the current configuration of the robot
    % ========================================== %
    body = [];
    fprintf('Loading STL''s...\n');
    body.trunk.stl = stlread('trunk.STL');
    body.trunk.stl.vertices = body.trunk.stl.vertices+[-0.013,0,0];
    body.trunk.function = @(x)H_trunk(x);
    body.COM.function = @(x)pcom_A1(x);
    fprintf('Done Loading STL''s\n');
    robot_obj = Animate(time,stateData,body,cameraView,movieName,varargin{:});
end