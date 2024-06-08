function [dopp_correct] = remove_range_migration(removeRngMigration)
%REMOVERANGEWALK This function removes the effects of range walk from a
% radar data cube and returns the corrected datacube.
% 
% NOTE:
%   consider oversampling the pulses to mitigate signal loss for signal near
%   nyquist. Downsampling required at the end if this step is applied
arguments
    removeRngMigration.datacube {mustBeNonempty} = 0
    removeRngMigration.radar    {mustBeNonempty} = 0
    removeRngMigration.dopAmb   {mustBeNonempty} = 0
    removeRngMigration.dopOver  {mustBeNonempty} = 0
end
datacube    = removeRngMigration.datacube;
prf_hz      = removeRngMigration.radar.Prf_hz;
n_pulses    = removeRngMigration.radar.N_pulses;
dopp_amb_hz = removeRngMigration.dopAmb;
fs_hz       = removeRngMigration.radar.Fs_hz;
fc_hz       = removeRngMigration.radar.Freq_Center_hz;

% get radar datacube size
[n_pri, n_pulses] = size(datacube);

% create slow time vector
slow_time = (0:n_pulses_over -1)/prf_over;

% ceate fast time freq vector
frac_n_samp_pulse = (0:n_pri-1)'/n_pri;
idw = frac_n_samp_pulse >=1/2;
frac_n_samp_pulse(idw) = frac_n_samp_pulse(idw) - 1;
freq_bins = frac_n_samp_pulse *fs_hz;

% move to fast time freq domain
data = fft(datacube,[],1);

% now perform interploation to rescale/resample the slow time axis.
% can choose from a number of interpolation methods: Sinc, Linear, Cubic,
% Spectral via the chirp Z-Transform

% Interpolate 1 range line/fast time frequency sample at a time

% create time vector to upsample to
ref_time_vec=0;

% loop over each PRI and interpolate
    % for each PRI in a CPI
        % get the current interpolation value for this time 
        % interpolate using original slow time vector, data for all frequency bins
        % within this PRI i.e. data(PRI,:), and reference time vector
        % this method will upsample the original slow time vector to the 
        % reference time vector. 
        

% apply doppler ambiguity fix by creating doppler correction phase argument
% and multiplying it by interpolated signal
dopp_correct = exp(1j*2*pi*dopp_amb_hz*prf_hz*ref_time_vec);


% move data back to time domain ifft(data,[],1);
end

