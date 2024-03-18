clear
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
% Reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
% Range and Doppler FFT sizes respectively.
Mix = rx_data_ant1_fast_slow;
Nr =  size(rx_data_ant1_fast_slow,1);
Nd = size(rx_data_ant1_fast_slow,2);

% Run the FFT on the beat signal along the range bins dimension (Nr) and
% normalize.
Mix_fft = fft(Mix, [], 1);
Mix_fft = (Mix_fft - min(Mix_fft, [], 1)) ./ (max(Mix_fft, [], 1) - min(Mix_fft, [], 1));

% Take the absolute value of FFT output to get the magnitude of the signal
Mix_fft = abs(Mix_fft);

% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Thereforee we throw out half of the samples.
Mix_fft = Mix_fft(1:Nr/2,:);

% Plot the range to the target
figure (1)
subplot(2,1,1)

% plot FFT output
first_chirp = 1;
plot(Mix_fft(first_chirp,:))
title('Range from First FFT (Chirp #1)')
xlabel('Range (m)')
ylabel('Amplitude')
axis ([0 (max_range + 20) 0 1]);

subplot(2,1,2)
last_chirp = Mix_fft(radar.num_samples_per_chirp,:);
plot(last_chirp)
title('Range from Last FFT (Chirp #128)')
xlabel('Range (m)')
ylabel('Amplitude')
axis ([0 (max_range + 20) 0 1]);