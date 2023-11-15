function T = H_trunk(x)
    T = [R_YPR(x(4:6)),x(1:3);
         zeros(1,3),1];
end

