function [COM_targets] = getCOMTargetTrajectory_Footholds(params)
%GETCOMTARGETTRAJECTORY_FOOTHOLDS Summary of this function goes here
%   Detailed explanation goes here
[~,num_cols] = size(params.contact_matrix);
COM_targets = zeros(2*params.Nd,num_cols);
for k=1:num_cols
    contacts = params.foot_holds(:,k);
    x = contacts(1:2:end);
    y = contacts(2:2:end);
    COM_targets(1:2,k) = [mean(x(isfinite(x)));mean(y(isfinite(y)))];
end

for k=2:num_cols-1
    if isequal(params.contact_matrix(:,k),params.contact_matrix(:,k+1))
        COM_targets(3:2*params.Nd,k)=repmat([COM_targets(1:2,k)],params.Nd-1,1);
    else
        increment = (COM_targets(1:2,k+1)-COM_targets(1:2,k))/params.Nd;
        for i=1:params.Nd-1
            COM_targets(2*i+1:2*(i+1),k) =  COM_targets(2*i-1:2*(i),k)+ increment;
        end
    end
end

COM_targets(3:2*params.Nd,num_cols) = repmat([COM_targets(1:2,num_cols)],params.Nd-1,1); 

end
