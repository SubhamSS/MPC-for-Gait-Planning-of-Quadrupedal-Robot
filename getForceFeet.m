function [GRF_forces] = getForceFeet(Net_force_xy,lambdas_contact,contact_indicator_feet,params)
%GETFORCEFEET Summary of this function goes here
%   Detailed explanation goes here
samples = length(contact_indicator_feet);
number_of_feet_cont = sum(contact_indicator_feet);
weight = params.mass*params.g;
feet_force = zeros(12,samples);
for k=1:samples
    feet_force(1,k) = lambdas_contact(1,k)*Net_force_xy(1,k);
    feet_force(2,k) = lambdas_contact(1,k)*Net_force_xy(2,k);
    feet_force(3,k) = contact_indicator_feet(1,k)*weight/number_of_feet_cont(k);
    
    feet_force(4,k) = lambdas_contact(2,k)*Net_force_xy(1,k);
    feet_force(5,k) = lambdas_contact(2,k)*Net_force_xy(2,k);
    feet_force(6,k) = contact_indicator_feet(2,k)*weight/number_of_feet_cont(k);

    feet_force(7,k) = lambdas_contact(3,k)*Net_force_xy(1,k);
    feet_force(8,k) = lambdas_contact(3,k)*Net_force_xy(2,k);
    feet_force(9,k) = contact_indicator_feet(3,k)*weight/number_of_feet_cont(k);

    feet_force(10,k) = lambdas_contact(4,k)*Net_force_xy(1,k);
    feet_force(11,k) = lambdas_contact(4,k)*Net_force_xy(2,k);
    feet_force(12,k) = contact_indicator_feet(4,k)*weight/number_of_feet_cont(k);

end
GRF_forces = feet_force';

end

