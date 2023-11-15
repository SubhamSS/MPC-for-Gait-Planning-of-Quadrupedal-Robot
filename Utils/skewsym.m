function [skewMat] = skewsym(x)
% Turns a vector into a skew symmetric representation
%
% Inputs: 
%   x - a 3x1 or 1x3 vector
% Outputs:
%   skewMat - the skew symmetric matrix corresponding to the input vector

skewMat = [    0, -x(3),  x(2);
            x(3),     0, -x(1);
           -x(2),  x(1),     0];
end 