function [Ad,Bd, A,B] = getDynamics(params)
% GETDYNAMICS Summary of this function goes here
%   Detailed explanation goes here

A = [0 1 0 0; params.g/params.height 0 0 0; 0 0 0 1; 0 0 params.g/params.height 0 ];
B = [0 0; -params.g/params.height 0; 0 0; 0 -params.g/params.height];


%ZOH for 
system = ss(A,B,[],[]);
system_dis = c2d(system,params.Ts,'zoh');
Ad = system_dis.A;
Bd = system_dis.B;

%Euler
% Ad = params.Ts*A + eye(size(A));
% Bd = params.Ts*B;

end

