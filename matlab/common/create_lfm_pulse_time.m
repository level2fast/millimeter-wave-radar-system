function [lfm_signal] = create_lfm_pulse_time(lfmP)
%CREATE_LFM_PULSE_SAMPLES Summary of this function goes here
%   This function synthesizes a linear FM pulse. An LFM pusle is a sinusoid
%   whose frequency changes linearly from some low value to a high value or
%   vice versa. The formula for such a signal can be represented as a
%   complex exponential with quadratic phase:
%   lfm_pulse = e^(j*s(t))
%       where
%           s(t) = 2*pi*alpha*t^2 + 2*pi*fc*t+phi
%       and
%       fs = signal sample rate. Specified as a positive scalar (Hz)
%       F0 = Start frequency (Hz)
%       F0 = End frequency (Hz)
%       T = Total duration of pulse
%       chirpUpDown = indicates a positive frequency slope (+1) or a negative frequency slope (-1)
arguments
    lfmP.Fs (1,1) {mustBeNonnegative}  = 0 
    lfmP.F0 (1,1) {mustBeNonnegative}  = 0 
    lfmP.F1 (1,1) {mustBeNonnegative}  = 0 
    lfmP.T  (1,1) {mustBeNonnegative}  = 0 
    lfmP.ChirpUpDown (1,1) {mustBeNonnegative}  = 0 
end
sweep_bandwidth = lfmP.Fs * lfmP.T;
f1_hz = lfmP.F1;
f0_hz = lfmP.F0;
pulse_duration_s = lfmP.T;
phi = 0;
if(sweep_bandwidth/2 > lfmP.Fs)
    disp('Warning: aliasing will be produced since BW/2 > fs')
end

if(lfmP.ChirpUpDown==-1)
temp = lfmP.F0;
lfmP.F0 = lfmP.F1;
lfmP.f1=temp;
end

dt = 1/lfmP.fs;
time_vec_s = 0:dt:lfmP.T-(1/lfmP.Fs);
k = (f1_hz - f0_hz) / pulse_duration_s;
freqz_hz = 2 * pi * ((k/2) .* time_vec_s + f0_hz) .* time_vec_s +phi;
theta = freqz_hz + phi;
lfm_signal = exp(1j*theta);
end

