function [n_samp_pri] = calc_n_samp_per_pulse(radar)
%UNTITLED Calculates the number of samples per pulse (samples/pulse)
%   Detailed explanation goes here
arguments
    radar.Fs (1,1) {mustBeNumeric} = 0
    radar.Prf (1,1) {mustBeNumeric} = 0
end
n_samp_pri = round(radar.Fs/radar.Prf);
end

