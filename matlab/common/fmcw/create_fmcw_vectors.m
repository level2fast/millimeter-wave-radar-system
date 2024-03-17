function [range_vector,doppler_vector,slow_time_vector] = create_fmcw_vectors(radar)
%CREATEvectorS Summary of this function goes here
%   Detailed explanation goes here
arguments
    radar.Fs_hz     (1,1) {mustBeNonnegative}  = 4.5e6    % sampling rate
    radar.Prf_hz    (1,1) {mustBeNonnegative}  = 1/100e6; % chirp repitition frequency
    radar.NumChirps (1,1) {mustBeNonnegative}  = 128      % number of chirps in a frame
end
n_samp_pri   = round(radar.Fs_hz/radar.Prf);            % number of samples for 1 chirp repitition interval (PRI)
delta_r      = physconst('LightSpeed')/(2*radar.Fs_hz); % represents spacing between range vector samples
range_vector = (0:n_samp_pri-1) *delta_r;            % number of samples within a PRI spaced by delta_r

% create a vector with values that are spaced by PRI time.Recall that the time step across 
% slow time is PRI=1/PRF. The sample rate of the ADC is much faster than 
% the PRF, and for this reason fast time earns it's name and conversley how
% slow time earns its name.
slow_time_vector = (0:(radar.NumChirps-1))/radar.Prf_hz; 

% create our doppler vector. Doppler vector spacing, always between (-prf/2):(prf/2)
delta_f = radar.Prf_hz/radar.NumChirps;
doppler_vector = -radar.Prf_hz/2:delta_f:((radar.Prf_hz/2)-delta_f);
end

