function [Xout] = applyAction(X0,U,params)
%APPLYACTION Summary of this function goes here
%   Detailed explanation goes here
Ad = params.Ad;
Bd = params.Bd;
n_actions = params.n_actions;
m= params.m;
n=params.n;
Xout = zeros(n*n_actions,1);

for i=1:n_actions
    Xout(n*(i-1)+1:n*i,1) = Ad*X0+Bd*U(m*(i-1)+1:m*i,1);
    X0 = Xout(n*(i-1)+1:n*i,1);
end

end

