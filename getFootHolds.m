function [foot_holds] = getFootHolds(params)
%GETFOOTHOLDS Summary of this function goes here
%   Detailed explanation goes here;
[~,num_cols] = size(params.contact_matrix);
[a,b] = size(params.p_foot);
foot_holds = zeros(8,num_cols);
foot_holds(:,1) = reshape(params.p_foot,a*b,1);
foot_holds(:,2) = reshape(params.p_foot,a*b,1);
foot_holds(3:6,2)=inf*ones(4,1);

for i=3:num_cols
    for j=1:4
        if params.contact_matrix(j,i)==1
            if params.contact_matrix(j,i-1)==1
                foot_holds(2*j-1:2*j,i)=foot_holds(2*j-1:2*j,i-1); %check for previous foot holds, since it should work for last 20 domains of stopping in place
            else
                foot_holds(2*j-1:2*j,i)=foot_holds(2*j-1:2*j,i-2)+params.desired_step;
            end
        else
            foot_holds(2*j-1:2*j,i)=[inf;inf];
        end
    end

end

end

