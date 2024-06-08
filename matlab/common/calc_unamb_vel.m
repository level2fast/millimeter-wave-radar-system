function [unambiguous_velocity] = calc_unamb_vel(unambigV)
%CALC_UNAMB_RNG Calculate the maximum radial velocity that can be observed without ambiguity.
%   The maximum radial velocity that can be observed without ambiguity.
%   This function calculate the maximum unambiguous velocity for target
%   detected using a a radar of wavelength lambda(m) and operating 
%   at the PRF(Hz) specified as a parameter to this function.
arguments
unambigV.Prf_hz (1,1) {mustBeNonnegative}  = 0 
unambigV.lambda_m (1,1) {mustBeNonnegative}  = 0 
end
unambiguous_velocity = (unambigV.Prf_hz*unambigV.lambda_m)/4;
end

