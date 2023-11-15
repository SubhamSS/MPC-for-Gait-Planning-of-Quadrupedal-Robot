function [dx] = Dynamics(t,X,U,params)
%DYNAMICS Summary of this function goes here
%   Detailed explanation goes here

A = [0 1 0 0; params.g/params.real_height 0 0 0; 0 0 0 1; 0 0 params.g/params.real_height 0 ];
B = [0 0; -params.g/params.real_height 0; 0 0; 0 -params.g/params.real_height];

dx = A*X + B*U;
end

