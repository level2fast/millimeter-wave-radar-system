function [power] = conv_pow_sqrd_to_linear(decibelsPowSqrd)
%CONVERTPOWERTOLINEAR Summary of this function goes here
%   Detailed explanation goes here
if isvector(decibelsPowSqrd)
    power = 10.^(decibelsPowSqrd/20);
else
    power = 10^(decibelsPowSqrd/20);
end

