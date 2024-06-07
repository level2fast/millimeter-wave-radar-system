function [range_vector,doppler_vector,slow_time_vector] = create_vectors(radar)
%CREATEVECTORS Builds range, doppler, and slow time vectors for pulsed radar.
%   Detailed explanation goes here
arguments
    radar.Fs       (1,1) {mustBeNonnegative}  = 0 % sampling rate
    radar.Prf      (1,1) {mustBeNonnegative}  = 0 % pulse repitition frequency
    radar.NumPulse (1,1) {mustBeNonnegative}  = 0 % number of pulses in a CPI
    radar.Bandwidth (1,1) {mustBeNonnegative}  = 0 % bandwidth of radar
end
n_samp_pri   = round(radar.Fs/radar.Prf); % number of samples for 1 pulse repitition interval (PRI)
delta_r      = physconst('LightSpeed')/(2*radar.B); % represents spacing between range vector samples
range_vector = (0:n_samp_pri-1) *delta_r; % number of samples within a PRI spaced by delta_r

% create a vector with values that are spaced by PRI time.Recall that the time step across 
% slow time is PRI=1/PRF. The sample rate of the ADC is much faster than 
% the PRF, and for this reason fast time earns it's name and conversley how
% slow time earns its name.
slow_time_vector = (0:(radar.NumPulse-1))/radar.Prf; 

% create our doppler vector. Doppler vector spacing, always between (-prf/2):(prf/2)
delta_f = radar.Prf/radar.NumPulse;
doppler_vector = -radar.Prf/2:delta_f:((radar.Prf/2)-delta_f);
end

