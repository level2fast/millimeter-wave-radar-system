function [number_of_pulses] = calc_n_pulse_per_cpi(radarData)
%CALC_N_PULSE_PER_CPI Summary of this function goes here
%   Detailed explanation goes here
arguments
    radarData.Prf      (1,1) {mustBeNonnegative}  = 0  %pulse repitition frequency 
    radarData.Dwell    (1,1) {mustBeNonnegative}  = 0 % 
end
number_of_pulses = radarData.Prf * radarData.Dwell;
end

