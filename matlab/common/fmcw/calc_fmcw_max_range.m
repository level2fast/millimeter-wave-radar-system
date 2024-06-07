function [maximum_range] = calc_fmcw_max_range(maxRange)
%CALC_FMCW_MAX_RANGE Calculates the maximum range of an FMCW radar 
% 
%   Calculation is based on the intermediate frequency and the chirp slope
arguments
    maxRange.if_max (1,1) {mustBePositive} = 0
    maxRange.chirp_slope (1,1) {mustBePositive} = 0
end
c = physconst('LightSpeed');
maximum_range = (maxRange.if_max * c)/(2 *maxRange.chirp_slope);
end

