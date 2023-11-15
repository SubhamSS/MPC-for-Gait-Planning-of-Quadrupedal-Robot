function [State_trajectory] = getTargetTrajectory(params)
%GETTARGETTRAJECTORY Summary of this function goes here
%   Detailed explanation goes here
[len,wid] = size(params.COM_target_trajectory);
COM_targets = params.COM_target_trajectory;
COM_targets_resize = reshape(COM_targets,2,len*wid/2);
[lenr,widr]= size(COM_targets_resize);
State_trajectory = zeros(2*lenr,widr);
State_trajectory(1,:) = COM_targets_resize(1,:);
State_trajectory(3,:) = COM_targets_resize(2,:);
end

