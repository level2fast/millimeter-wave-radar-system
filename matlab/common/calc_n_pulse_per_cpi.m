function [number_of_pulses] = calc_n_pulse_per_cpi(radarData)
%CALC_N_PULSE_PER_CPI Calculate number of pulses per cpi using prf and dwell time.
%   Detailed explanation goes here
arguments
    radarData.Prf      (1,1) {mustBeNonnegative}  = 0  % pulse repitition frequency 
    radarData.Dwell    (1,1) {mustBeNonnegative}  = 0 %  dwell time
end
number_of_pulses = radarData.Prf * radarData.Dwell;
end

