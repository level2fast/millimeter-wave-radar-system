clear
clf
rx_data = read_dca_1000(file_name="adc_data.bin");
%% IWR68843AOP Medium Range Radar(MRR) Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 60GHz
% Max Range = 20m
% Range Resolution = 0.1 m
% Max Velocity = 10 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define simulation constants
lightspeed = physconst('LightSpeed');
%% Define Radar parameters
radar = FmcwRadar();
radar.Freq_Center_hz      = 60e9;
radar.Bandwidth_hz        = 1500e6;
radar.chirp_dur_secs      = 50*1e6;
radar.frame_time_secs     = 12.8*1e3;
radar.Lambda_m            = freq2wavelen(radar.Freq_Center_hz,lightspeed); % Wavelength (m)
radar.Prf_hz              = 1/100e6;
radar.num_chirps          = 128;
radar.Fs_hz               = 4.5e6 *10; % 2*(IF or Max beat freq)
max_range                 = 22; % maximum unambiguous range
%% Process 1 RX channel of data
rx_data_ant1 = rx_data(1,:);
rows = (size(rx_data_ant1,2)/radar.num_samples_per_chirp);
cols = radar.num_samples_per_chirp;
rx_data_ant1_fast_slow = reshape(rx_data_ant1,[rows,cols]);

%% RANGE MEASUREMENT
% Reshape the vector into num_rows*num_cols array. num_rows and num_cols here would also define the size of
% Range and Doppler FFT sizes respectively.
beat_signal = rx_data_ant1_fast_slow;
num_rows    = size(rx_data_ant1_fast_slow,1);
num_cols    = size(rx_data_ant1_fast_slow,2);

% Plot range axis
B       = radar.Bandwidth_hz; % Bandwidth (150 MHz)
T_chirp = radar.chirp_dur_secs; % Chirp duration (5.5 microseconds)
c       = 3e8; % Speed of light
fs      = radar.Fs_hz; % Sampling frequency (2 MHz)
N_FFT   = radar.num_samples_per_chirp; % Size of the FFT

% Calculate Range Resolution
delta_R = c / (2 * B);

% Calculate Maximum Range (optional simplification for visualization)
if_max_hz = 4.5e6;
slope_hz_us = 30e6;
range_max = if_max_hz *c /(2*slope_hz_us);
msg = sprintf("Max Range: %0.2f meters",range_max/1e6);
disp(msg);

% Run the FFT on the beat signal along the range bins dimension.
range_fft = fft(beat_signal, N_FFT);
range_fft = (range_fft - min(range_fft, [], 1)) ./ (max(range_fft, [], 1) - min(range_fft, [], 1));
% Take the absolute value of FFT output to get the magnitude of the signal
range_fft = abs(range_fft(1:N_FFT/2)); % Take first half since FFT is symmetric

% Generate Range Axis
range_axis = (0:N_FFT/2-1) * (delta_R);

% Plot
plot(range_axis, range_fft);
xlabel('Range (m)');
ylabel('Magnitude');
title('FMCW Radar Signal');
return;
% Plot the range to the target
% figure (1)
% subplot(3,1,1)
% 
% % plot FFT output
% first_chirp = 1;
% plot(mix_fft(first_chirp,:))
% title('Range from First FFT (Chirp #1)')
% xlabel('Range (m)')
% ylabel('Amplitude')
% axis ([0 (max_range + 20) 0 1]);
% 
% subplot(3,1,2)
% last_chirp = mix_fft(end,:);
% plot(last_chirp)
% title('Range from Last FFT (Chirp #1024)')
% xlabel('Range (m)')
% ylabel('Amplitude')
% axis ([0 (max_range + 20) 0 1]);

%% Apply a window to the time domain signal to reduce spectral leakage
win = chebwin(length(beat_signal));
beat_signal = win.* beat_signal;

%% RANGE DOPPLER RESPONSE
% A 2DFFT will be run on the mixed signal (beat signal) output to generate
% a range doppler map.

% Range Doppler Map Generation.
% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

% 2D FFT using the FFT size for both dimensions.
sig_rng_dopp_freq = fft2(mix,num_rows,num_cols);

% Taking just one side of signal from Range dimension.
sig_rng_dopp_freq = sig_rng_dopp_freq(1:num_rows,1:num_cols/2);
sig_rng_dopp_freq = fftshift(sig_rng_dopp_freq);
RDM = abs(sig_rng_dopp_freq);
RDM = 10*log10(RDM) ;

% Use the surf function to plot the output of 2DFFT and to show axis in both
% dimensions
range_axis = linspace(-200,200,num_cols/2)*((num_cols/2)/400);
doppler_axis = linspace(-100,100,num_rows);

[range_axis, doppler_axis, ~] = create_vectors(Fs=radar.Fs_hz,NumPulse=radar.num_chirps,Prf=radar.Prf_hz);

figure(2)
surf(doppler_axis,range_axis,RDM);
title( 'RDM From 2D FFT');
xlabel('Velocity');
ylabel('Range');
zlabel('Amplitude (dB)');
colorbar;