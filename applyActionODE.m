function [Xout] = applyActionODE(t,X0,U,params)
%APPLYACTIONODE Summary of this function goes here
%   Detailed explanation goes here
n_actions = params.n_actions;
m= params.m;
n=params.n;
Xout = zeros(n*n_actions,1);
Ts = params.Ts;

 for i=1:n_actions
     [t_out,X] = ode45(@(t,X)Dynamics(t,X,U(m*(i-1)+1:m*i,1),params),[t,t+Ts],X0);
     Xout(n*(i-1)+1:n*i,1) = X(end,1:4);
     X0 = X(end,1:4);
 end


end


