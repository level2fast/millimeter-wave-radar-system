function [freq_bins] = create_fast_time_freq(fastTime)
%CREATE_FAST_TIME_FREQ Creates fast time frequency samples for a given number of pulses
%   Detailed explanation goes here
arguments
    fastTime.NumSampPerPulse (1,1) = 0 
    fastTime.SampleRate_Hz   (1,1) = 0 
    fastTime.NumPulses       (1,1) = 0 
end

n_samp_per_pulse = fastTime.NumSampPerPulse;
fs_hz = fastTime.SampleRate_Hz;

% create frequency bins by converting fractional sample per pulse 
% vector into a vector representing the spacing in the frequency domain.
frac_n_samp_pulse      = (0:n_samp_per_pulse-1)' / n_samp_per_pulse; 
idx                    = frac_n_samp_pulse >= 1/2;
frac_n_samp_pulse(idx) = frac_n_samp_pulse(idx) - 1;
freq_bins              = frac_n_samp_pulse * fs_hz;
end


