function [lfm_signal] = create_lfm_pulse_samples(lfmP)
%CREATE_LFM_PULSE_SAMPLES Synthesizes a linear FM pulse based a number of samples
%   This function synthesizes a linear FM pulse. An LFM pusle is a sinusoid
%   whose frequency changes linearly from some low value to a high value or
%   vice versa. The formula for such a signal can be represented as a
%   complex exponential with quadratic phase:
%   lfm_pulse = e^(j*s(t))
%       where
%           s(t) = 2*pi*alpha*t^2 + 2*pi*fc*t+phi
%       and
%       fs = signal sample rate. Specified as a positive scalar (Hz)
%       sweepBandwidth = length of the frequncy ramp in (Hz)
%       numberOfSamples = Total amount of samples used
%       causal = specifies domain of signal. causal(0), non-causal(1)
%       chirpUpDown = indicates a positive frequency slope (+1) or a negative frequency slope (-1)
arguments
lfmP.Fs (1,1) {mustBeNonnegative}  = 0 
lfmP.SweepBandwidth (1,1) {mustBeNonnegative}  = 0 
lfmP.NumberOfSamples (1,1) {mustBeNonnegative}  = 0 
lfmP.ChirpUpDown (1,1) {mustBeNonnegative}  = 0 
lfmP.Causal (1,1) {mustBeNonnegative}  = 0 
end

time_vec_s = 0;
pulse_duration_s = 0;
N = 0;
f0_hz = 0;
f1_hz = 0;
phi = 0;

if(lfmP.SweepBandwidth/2 > lfmP.Fs)
    disp('Warning: aliasing will occur since BW/2 > fs')
end

if(lfmP.ChirpUpDown == -1)
    f0_hz = (-lfmP.SweepBandwidth/2) *-1;
    f1_hz = (lfmP.SweepBandwidth/2) *-1;
else
    f0_hz = (0);
    f1_hz = (lfmP.SweepBandwidth);
end

if(lfmP.Causal == 0)
    % total duration of pulse(secs)
    pulse_duration_s = lfmP.NumberOfSamples/lfmP.Fs;
    % our starting point would be zero instead of number samples/2
    time_vec_s = 0:1/lfmP.Fs:pulse_duration_s-(1/lfmP.Fs);
else % non-causal
    % N is our sample vector which counts the number of samples in this pulse.
    % Our starting point is numberOfSamples/2. The -1 accounts for MATLABS
    % indexing
    N = -lfmP.NumberOfSamples/2:lfmP.NumberOfSamples/2-1;

    % time vector is number of samples / sampling rate = secs/pulse
    time_vec_s = N/lfmP.Fs;
    pulse_duration_s = lfmP.NumberOfSamples/lfmP.Fs;
end

k = (f1_hz - f0_hz) / pulse_duration_s;
freqz_hz = 2 * pi * ((k/2) .* time_vec_s + f0_hz) .* time_vec_s +phi;
theta = freqz_hz + phi;
lfm_signal = exp(1j*theta);
end

