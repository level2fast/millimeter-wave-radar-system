function [power] = conv_pow_to_linear(decibelsPow)
%CONVERTPOWERTOLINEAR Summary of this function goes here
%   Detailed explanation goes here
if isvector(decibelsPow)
    power = 10.^(decibelsPow/10);
else
    power = 10^(decibelsPow/10);
end

