%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Millimeter Wave Radar Target Generation and Detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear last_chirp
clear
clc;

%% IWR68843AOP Medium Range Radar(MRR) Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 60GHz
% Max Range = 20m
% Range Resolution = 1 m
% Max Velocity = 10 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define simulation constants
c_mps = physconst('LightSpeed');
%% Define Radar parameters
radar = Radar();
radar.Freq_Center_hz     = 60e9;
radar.Bandwidth_hz       = 1500e6;  % bandwidth in Hz 
radar.Chirp_Duration_us  = 50; % chirp duration in microseconds
chirp_duration_s         = radar.Chirp_Duration_us/1e6;
radar.Lambda_m           = c_mps/radar.Freq_Center_hz; % Wavelength (m)
radar.Prf_hz             = 1/chirp_duration_s;
radar.N_Chirps           = 512;
radar.Fs_hz              = 5e6;
max_if_freq              = 4.5e6;
slope_hz_s               = radar.Bandwidth_hz/chirp_duration_s;

% CA-CFAR parameters
training_cells_range   = 4;
training_cells_doppler = 4;
gaurd_cells_range      = 2;
gaurd_cells_doppler    = 2;
pfa = 1e-4; % probability of false alarm

%% Define Range and Velocity of target
% Define the target's initial position and velocity. Note : Velocity
% remains contant in this sim
target = Target();
target.Plat_Pos_m   = 10;
target.Plat_Vel_m_s = 9.58; % 9.58 Usain Bolts World record in Velocity falls within the range of our radar
target_doppler_freq_hz = (-2*target.Plat_Vel_m_s)/radar.Lambda_m;
fprintf(1,'Target Name \n\tUsain Bolt \n');
fprintf(1,'Target Range  \n\t%2.2f m \n',target.Plat_Pos_m);
fprintf(1,'Target Velocity  \n\t%2.2f m/s\n',target.Plat_Vel_m_s);
fprintf(1,'Target Doppler Frequency \n\t%2.2f Hz\n\n',target_doppler_freq_hz);


%% FMCW Waveform Generation
% Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.
% Get operational parameters from radar to use in tx and rx processing

% Define/get radar parameters needed for sim
fc_hz              = radar.Freq_Center_hz;
max_range_m = (max_if_freq * c_mps)/ (2*slope_hz_s);

% print important radar parameters 
fprintf(1,'Radar Max Range         \n\t%0.2f meters \n',max_range_m);
fprintf(1,'Radar Center Frequency  \n\t%2.2f GHz \n',radar.Freq_Center_hz/1e9);
fprintf(1,'Radar Sampling Rate  \n\t%2.2f MHz \n',radar.Fs_hz/1e6);
fprintf(1,'Radar Chirp Duration \n\t%2.1f us \n',radar.Chirp_Duration_us);
fprintf(1,'Radar Bandwidth      \n\t%2.2f MHz\n',radar.Bandwidth_hz/1e6);
fprintf(1,'Radar Pulse Repitition frequency \n\t%2.2f KHz \n',radar.Prf_hz/1e3);
fprintf(1,'Radar Pulses \n\t%2.2f  \n',radar.N_Chirps);
fprintf(1,'Radar Max Beat Freq  \n\t%2.2f Mhz  \n',15);

% Calculate range resolution
range_resolution = c_mps/(2* radar.Bandwidth_hz);
fprintf(1,'Radar Range Resolution \n\t%2.2f m\n',range_resolution);

% Calculate velocity resolution
vmax = calc_fmcw_max_velocity("lambda",radar.Lambda_m,"total_chirp_time_s",chirp_duration_s);
vres = calc_fmcw_max_velocity_res("lambda",radar.Lambda_m,"num_chirps_in_frame",radar.N_Chirps,"total_chirp_time",chirp_duration_s);
fprintf(1,'Radar Max Doppler Freq  \n\t%2.2f Hz  \n',radar.Prf_hz/2);
fprintf(1,'Radar Max Velocity  \n\t%2.2f meters/sec  \n',vmax);
fprintf(1,'Radar Velocity Resolution  \n\t%2.2f meters/sec  \n\n',vres);

% Get the number of chirps in one sequence. Its ideal to have 2^ value for the 
% ease of running the FFT  for Doppler Estimation. 

% Get #of doppler cells OR # number of chirps
Nd = radar.N_Chirps;         

% Get the number of samples on each chirp. 
n_samples_per_chirp = round(radar.Fs_hz/radar.Prf_hz);

% Get # of range cells
Nr = n_samples_per_chirp;    

% Total time for samples, generate a linearly spaced vector between 0 and 
% the sum of all PRI's. The number of points in the vector is equal to the 
% to the total number of samples in a CPI. 
time_s = 0:1/radar.Fs_hz:chirp_duration_s - (1/radar.Fs_hz); 

% Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(time_s));    % transmitted signal, represents the signal that leaves the antenna
Rx=zeros(1,length(time_s));    % received signal, represents the echo from a target
Mix = zeros(Nr,Nd); % beat signal, produced by mixing rx signal echo's with tx signal

% Similar vectors for range_covered and time delay.
range_slow_time = zeros(1,length(time_s)); % represents a targets dipslacement with respect to the range axis
time_delay_s      = zeros(1,length(time_s)); % represents total time delay as a function of a targets range
doppler_shift_Hz = 2*target.Plat_Vel_m_s / radar.Lambda_m;
%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 
slow_time_axis =(0:Nd-1)/radar.Prf_hz;
for chirp_idx=1:Nd
    % For each time step update the Range of the Target for constant velocity. 
    
    % First calculate range time delay for simulating a targets displacement with
    % respect to the range time axis
    range_slow_time = target.Plat_Pos_m + time_s * target.Plat_Vel_m_s;
    time_delay_s      = 2 * range_slow_time / c_mps;
    
    % Next we need update the transmitted and received signal time sample
    Tx = exp(1j* 2 * pi * ( fc_hz * time_s + slope_hz_s * time_s.^2 / 2 ));

    % Apply Doppler shift to the received signal for each chirp
    % The Doppler shift modifies the frequency of the received signal
    doppler_phase_shift = exp(-1j * 2 * pi * slow_time_axis(chirp_idx)*(doppler_shift_Hz));

    Rx = exp(-1j* 2 * pi * ( fc_hz * (time_s - time_delay_s) + ( slope_hz_s * ( time_s - time_delay_s ).^2) / 2 ));
    
    % Induce doppler frequency shift for this pulse
    Rx = Rx .* doppler_phase_shift;

    % Now we create the beat signal by mixing the transmit and receive. This
    % is done by an element wise matrix multiplication of transmit and receiver signal
    Mix(:, chirp_idx) = Tx .* Rx;
end

%% RANGE MEASUREMENT
% Reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
% Range and Doppler FFT sizes respectively.
Mix_rng_meas = reshape(Mix, [Nr, Nd]);
fft_len = 2^(nextpow2(n_samples_per_chirp));

% Run the FFT on the beat signal along the range bins dimension (Nr) and
% normalize.
Mix_fft = fft(Mix_rng_meas, fft_len, 1);
Mix_fft = (Mix_fft - min(Mix_fft, [], 1)) ./ (max(Mix_fft, [], 1) - min(Mix_fft, [], 1));

% Take the absolute value of FFT output to get the magnitude of the signal
Mix_fft = abs(Mix_fft);

% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Therefore we throw out half of the samples.
Mix_fft = Mix_fft(1:n_samples_per_chirp,:);

% Plot the range to the target
figure (1)
subplot(2,1,1)
% create range frequencies
range_axis = (0:n_samples_per_chirp-1) * radar.Fs_hz/n_samples_per_chirp;
% plot FFT output
first_chirp = 1;
plot(range_axis/1e6, Mix_fft(:,first_chirp))
title('Range from First FFT (Chirp #1)')
xlabel('Range (MHz)')
ylabel('Amplitude')

subplot(2,1,2)
plot(range_axis/1e6, Mix_fft(:, radar.N_Chirps))
title('Range from Last FFT (Chirp #128)')
xlabel('Range (MHz)')
ylabel('Amplitude')

figure (2)
subplot(2,1,1)
% create range frequencies
range_axis = (0:n_samples_per_chirp-1) * radar.Fs_hz/n_samples_per_chirp;
range_axis_m = range_axis * (c_mps/(2*slope_hz_s));
% plot FFT output
first_chirp = 1;
plot(range_axis_m, Mix_fft(:,first_chirp))
title('Range from First FFT (Chirp #1)')
xlabel('Range (m)')
ylabel('Amplitude')

subplot(2,1,2)
plot(range_axis_m, Mix_fft(:, radar.N_Chirps))
title('Range from Last FFT (Chirp #128)')
xlabel('Range (m)')
ylabel('Amplitude')

%% Apply a window to the time domain signal to reduce spectral leakage
win_dop = kaiser(size(Mix,2),8).';
win_rng = hamming(size(Mix,1));
Mix = win_rng .* Mix;
Mix = Mix .* win_dop;
% Now, beat_signal contains your signal with the window applied to the Doppler & Range dimension

%% RANGE DOPPLER RESPONSE
% A 2DFFT will be run on the mixed signal (beat signal) output to generate
% a range doppler map.
% Range Doppler Map Generation.
% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

% Perform range and doppler processing
fft_size_rng = 2^nextpow2(size(Mix_fft,1));
range_fft = fft(Mix,fft_size_rng,1);
doppler_fft = fftshift(fft(range_fft, size(Mix,2),2),2);
sig_rng_dopp_freq = doppler_fft;
RDM = abs(sig_rng_dopp_freq);
RDM = 20*log10(RDM);

%% Plot RDM
% Compute Doppler Bin Frequencies
delta_fd = radar.Prf_hz / Nd;  % Doppler bin resolution
dopp_axis_hz = (-Nd/2 : Nd/2 - 1) * delta_fd;  % Doppler frequency axis
freq_axis_hz = (0:n_samples_per_chirp-1) * radar.Fs_hz/n_samples_per_chirp; % frequency spectrum data
freq_to_range_factor = c_mps/(2*slope_hz_s);
range_axis_m = freq_to_range_factor *freq_axis_hz;
figure(3)
imagesc(dopp_axis_hz/1e3,range_axis_m,RDM)
xlabel("Dopper(KHz)")
ylabel("Rang(m)")
axis xy
colorbar

% Find the peak values
[max_value, linear_index] = max(RDM(:));
% convert from linear index to (row, col) format
[row, col] = ind2sub(size(RDM),linear_index);

% Display results 
fprintf("RDM Results\n")
fprintf("------------------ \n")
disp(['Peak Value:', num2str(max_value)])
disp(['Range Bin:', num2str(row)])
disp(['Range(m):', num2str(range_axis_m(row))])
disp(['Doppler Bin:', num2str(col)])
disp(['Doppler Freq(Hz):', num2str(dopp_axis_hz(col))])
disp(['Velocity mps:', num2str(radar.Lambda_m* dopp_axis_hz(col)/2)])

% Use the surf function to plot the output of 2DFFT and to show axis in both
% dimensions
% Convert Doppler frequency to velocity
unambig_max_vel = (radar.Lambda_m / 4) * radar.Prf_hz;
velocity_axis = linspace(-unambig_max_vel, unambig_max_vel,radar.N_Chirps);
figure(4)
rng_axis_m = range_axis_m;
surf(velocity_axis, range_axis_m, RDM(1:250,:));
title( 'RDM From 2D FFT');
xlabel('Velocity(m/s)');
ylabel('Range(m)');
zlabel('Amplitude (dBFs)');
axis xy
colorbar;

%% Apply CFAR-CA to get detections
% calculate ragne axis
delta_R = c_mps / (2 * radar.Bandwidth_hz);
max_range = (n_samples_per_chirp - 1) * delta_R;
range_axis = linspace(-max_range, max_range, n_samples_per_chirp);

cfar_signal = cfar_2d_rdm_sim(Rdm=RDM(1:250,:), ...
    Pfa=pfa, ...
    NumRangeCells=Nr, ...
    NumDoppCells=Nd, ...
    dopplerAxis=velocity_axis, ...
    rangeAxis=range_axis, ...
    Tr=training_cells_range,...
    Td=training_cells_doppler,...
    Gd=gaurd_cells_range,...
    Gr=gaurd_cells_doppler,...   
    PlotData="false");

figure(5)
surf(rng_axis_m, velocity_axis, cfar_signal.', 'LineStyle', 'none');
alpha 0.75;
grid minor;
ylabel('velocity [m/s]');
xlabel('range [m]');
zlabel('signal strength [dBFs]')
title(sprintf('CA-CFAR filtered Range Doppler Response (Pfa=%d )', pfa))
colorbar;
colormap jet
axis xy


