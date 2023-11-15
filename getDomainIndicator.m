function [tau_k] = getDomainIndicator(params,k)
%DOMAININDICATOR Summary of this function goes here
%   Detailed explanation goes here
if k<params.M*params.Nd
    tau_k = floor(k/params.Nd) + 1;
else
    tau_k = params.M;
end
end

