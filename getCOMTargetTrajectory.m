function [COM_targets] = getCOMTargetTrajectory(params)
%GETCOMTARGETTRAJECTORY Summary of this function goes here
%   Detailed explanation goes here
%%THIS MAY BE WRONG SINCE IT DOESN'T CONSIDER THE LIP MODEL, IT JUST CAN'T
%%GO AHEAD IN EVERY STEP IN BOTH X AND Y OR ONLY ONE DIRECTION, LETS GO
%%FROM FOOT HOLD PERSPECTIVE
[~,num_cols] = size(params.contact_matrix);
increment_x = params.desired_step(1)/(2*params.Nd);
increment_y = params.desired_step(2)/(2*params.Nd);
increment = [increment_x;increment_y];
COM_targets = zeros(2*params.Nd,num_cols);
if params.contact_matrix(:,1)~=params.contact_matrix(:,2)
    COM_targets(1:2,1:2) = [0;0];%increment_x;increment_y;2*increment_x;2*increment_y;3*increment_x;3*increment_y]; %Knowing first step
end

for k=3:num_cols
    if isequal(params.contact_matrix(:,k-1),params.contact_matrix(:,k))
        COM_targets(1:2,k) = COM_targets(1:2,k-1);
    else
        COM_targets(1:2,k) = COM_targets(1:2,k-1)+ [params.desired_step(1)/2;params.desired_step(2)/2];
    end
end

for k=2:num_cols-1
    if isequal(COM_targets(1:2,k),COM_targets(1:2,k+1))
        COM_targets(3:2*params.Nd,k)=repmat([COM_targets(1:2,k)],params.Nd-1,1);
    else
        for i=1:params.Nd-1
            COM_targets(2*i+1:2*(i+1),k) =  COM_targets(2*i-1:2*(i),k)+ increment;
        end
    end

COM_targets(3:2*params.Nd,num_cols) = repmat([COM_targets(1:2,num_cols)],params.Nd-1,1); 

end

