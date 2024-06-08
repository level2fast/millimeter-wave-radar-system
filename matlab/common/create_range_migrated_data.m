function [rng_walk_sig] = create_range_migrated_data(rangeMigration)
%CREATE_RANGE_WALK_DATA Creates a radar signal that contains range walk. 
% 
%   Range walk is observed when there is coupling betwen the fast time
%   frequency and slow time range rate. This can be emulated in many different
%   ways. One of which is using a 1st order taylor series. 

arguments
    rangeMigration.radar      {mustBeNonempty} = 0
    rangeMigration.target     {mustBeNonempty} = 0
    rangeMigration.waveform   {mustBeNonempty} = 0
    rangeMigration.range_rate {mustBeNonempty} = 0
    rangeMigration.range      {mustBeNonempty} = 0
end
% grab input parameters
radar          = rangeMigration.radar;
freq_center_hz = radar.freq_center_hz;
prf_hz         = radar.prf_hz;
n_pulses       = radar.n_pulses;
c_mps          = radar.c_mps;
sample_rate_hz = radar.Fs_hz;
range          = rangeMigration.range;
range_rate     = rangeMigration.range_rate;

% get target info
trgt_range_rate = rangeMigration.target.range_rate_mps;
trgt_range      = rangeMigration.target.range;
trgt_rcs        = rangeMigration.target.rcs_dbsm;

relative_range_rate = range_rate - trgt_range_rate;
relative_range      = range - trgt_range;

% get our waveform
waveform = rangeMigration.waveform;

% create samples per pulse vector and slow time vector
n_samples_per_pulse = round(sample_rate_hz/prf_hz);
t_slow              = (0:n_pulses-1)/prf_hz;

% create frequency bins
frac_n_samp_pulse        =  (0:n_samples_per_pulse-1)'/n_samples_per_pulse;
idw = frac_n_samp_pulse  >= 1/2;
frac_n_samp_pulse(idw)   =  frac_n_samp_pulse(idw) - 1;
freq_bins                = frac_n_samp_pulse *sample_rate_hz;

% TODO SDD: plot slow time vs. freq bins before taylor adding range
% walk effects to slow time vector

tgt_acc_mps_sqrd = 0;

% create range slow time vector and apply range walk
range_walk = doppler_range_walk(relative_range_rate, t_slow) + tgt_acc_mps_sqrd/2*t_slow^2;
range_slow_time = relative_range + range_walk;

% TODO SDD: plot slow time vs. freq bins after adding range walk effects
% to slow time vector

% normalize waveform and FFT in range(i.e. columns)
waveform = waveform(:) / norm(waveform(:));
waveform_freq = fft(waveform,n_samples_per_pulse);

% create matrix to hold our RDM
sig_data = zeros(n_samples_per_pulse, n_pulses);

% add shift to this waveform to simulate range walk
range_phase = 4 * pi *(freq_bins + freq_center_hz) * range_slow_time/c_mps;
phase_shift = exp(-1j * range_phase);
tmp_data = waveform_freq .* phase_shift;

% add phase shifted data to the signal
tmp_data = ifft(tmp_data,[],1);
rng_walk_sig = sig_data + tmp_data;

% Plot fast freq vs. slow time 
% observe warping of slow time axis
end

