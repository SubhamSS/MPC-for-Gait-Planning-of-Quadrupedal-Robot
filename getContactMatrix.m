function [Contact_matrix] = getContactMatrix(params,stationary)
%GETCONTACTMATRIX Summary of this function goes here
%   Detailed explanation goes here


if stationary~=1
    Contact_matrix(:,1) = ones(4,1);

    for k=2:params.M-1
        if mod(k,2)==0
            Contact_matrix(:,k)=[1;0;0;1];
        else
            Contact_matrix(:,k)=[0;1;1;0];
        end
        Contact_matrix(:,params.M) = ones(4,1);
    
    end

else
    Contact_matrix = ones(4,params.M);
    
end

end



