function [U,Cl,A_eq,ft,lambda,lambdas_cont,contact_indicator] = getInputs(X_opt,C_lambda,Aeq_lam,foots,con_indicator,params)
%GETINPUTS Summary of this function goes here
%   Detailed explanation goes here
n=params.n;
m=params.m;
horizon = params.horizon;
n_actions = params.n_actions;

n_lambda_tot = length(X_opt(horizon*(n+m)+1:end));

U = X_opt(horizon*n+1:horizon*n+n_actions*m);

Cl = C_lambda(1:2*n_actions,:);
A_eq = Aeq_lam(1:n_actions,:);
ft = foots(:,1:n_actions);
n_lambda = sum(sum(A_eq));
lambda = X_opt(horizon*(n+m)+1:horizon*(n+m)+n_lambda);
contact_indicator = con_indicator(:,1:n_actions);
one_in_each = sum(contact_indicator);
[leng,bread] = size(contact_indicator);
lambdas_cont = zeros(size(contact_indicator));
counter =1;
for j=1:bread
    for k=1:leng
        if true(contact_indicator(k,j))
            lambdas_cont(k,j)=lambda(counter,1);
            counter=counter+1;
        end
    end
end






end

