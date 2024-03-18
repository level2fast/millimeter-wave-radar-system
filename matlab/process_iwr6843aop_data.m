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
radar.Fs_hz               = 9e6; % 2*(IF or Max beat freq)
max_range                 = 22; % maximum unambiguous range
%% Process 1 RX channel of data
rx_data_ant1 = rx_data(1,:);
rows = (size(rx_data_ant1,2)/radar.num_samples_per_chirp);
cols = radar.num_samples_per_chirp;
rx_data_ant1_fast_slow = reshape(rx_data_ant1,[rows,cols]);

%% RANGE MEASUREMENT
% Reshape the vector into num_rows*num_cols array. num_rows and num_cols here would also define the size of
% Range and Doppler FFT sizes respectively.
mix      = rx_data_ant1_fast_slow;
num_rows = size(rx_data_ant1_fast_slow,1);
num_cols = size(rx_data_ant1_fast_slow,2);

% Run the FFT on the beat signal along the range bins dimension (num_rows) and
% normalize.
mix_fft = fft(mix,radar.num_samples_per_chirp, 2);
mix_fft = (mix_fft - min(mix_fft, [], 2)) ./ (max(mix_fft, [], 2) - min(mix_fft, [], 2));

% Take the absolute value of FFT output to get the magnitude of the signal
mix_fft = abs(mix_fft);

% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Therefore we throw out half of the samples.
mix_fft = mix_fft(:,1:num_cols/2);

% Plot the range to the target
figure (1)
subplot(3,1,1)

% plot FFT output
first_chirp = 1;
plot(mix_fft(1,first_chirp))
title('Range from First FFT (Chirp #1)')
xlabel('Range (m)')
ylabel('Amplitude')
axis ([0 (max_range + 20) 0 1]);

subplot(3,1,2)
last_chirp = mix_fft(radar.num_samples_per_chirp,:);
plot(last_chirp)
title('Range from Last FFT (Chirp #1024)')
xlabel('Range (m)')
ylabel('Amplitude')
axis ([0 (max_range + 20) 0 1]);

%% Apply a window to the time domain signal to reduce spectral leakage
win = chebwin(length(mix));
mix = win.* mix;

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
figure(2)
surf(doppler_axis,range_axis,RDM);
title( 'RDM From 2D FFT');
xlabel('Velocity');
ylabel('Range');
zlabel('Amplitude (dB)');
colorbar;