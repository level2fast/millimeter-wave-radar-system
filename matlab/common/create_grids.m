function [range_grid,doppler_grid,slow_time_grid] = create_grids(radar)
%CREATEGRIDS Summary of this function goes here
%   Detailed explanation goes here
arguments
    radar.Fs       (1,1) {mustBeNonnegative}  = 0  % sampling rate
    radar.Prf      (1,1) {mustBeNonnegative}  = 0 % pulse repitition frequency
    radar.NumPulse (1,1) {mustBeNonnegative}  = 0 % number of pulses in a CPI
end
n_samp_pri = round(radar.Fs/radar.Prf); % number of samples for 1 pulse repitition interval (PRI)
delta_r = physconst('LightSpeed')/(2*radar.Fs); % represents spacing between range grid samples
range_grid = (0:n_samp_pri-1) *delta_r; % number of samples within a PRI spaced by delta_r

% create a vector with values that are spaced by a fraction or % of our PRF,
% index0=0% of PRF, index @ NumPulse=100% of PRF. Each integer index indicates 
% the end of a pulse and each fractional index indicates how far we are 
% looking within a pulse. Since pulses are viewed from the perspective of 
% time we could say that the slow time vector indices represent a fraction 
% of the time of each pulse we transmit.Recall that the time step across 
% slow time is PRI=1/PRF. The sample rate of the ADC is much faster than 
% the PRF, and for this reason fast time earns it's name and conversley how
% slow time earns its name.
slow_time_grid = (0:(radar.NumPulse-1))/radar.Prf; 


delta_f = radar.Prf/radar.NumPulse;
doppler_grid = -radar.Prf/2:delta_f:((radar.Prf/2)-delta_f); % doppler grid samples, always between (-prf/2):(prf/2)
end

