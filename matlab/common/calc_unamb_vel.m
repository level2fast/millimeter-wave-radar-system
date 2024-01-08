function [unambiguous_velocity] = calc_unamb_vel(unambigV)
%CALC_UNAMB_RNG Summary of this function goes here
%   Detailed explanation goes here
arguments
unambigV.Prf_hz (1,1) {mustBeNonnegative}  = 0 
unambigV.lambda_m (1,1) {mustBeNonnegative}  = 0 
end
c = physconst('LightSpeed');
unambiguous_velocity = (unambigV.Prf_hz*unambigV.lambda_m)/4;
end

