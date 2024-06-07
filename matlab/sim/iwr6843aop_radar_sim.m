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
lightspeed = physconst('LightSpeed');
%% Define Radar parameters
radar = Radar();
radar.Freq_Center_hz = 60e9;
radar.Bandwidth_hz   = 135e6;
radar.Pulse_Width_s  = 7e-6;
radar.Lambda_m       = freq2wavelen(radar.Freq_Center_hz,lightspeed); % Wavelength (m)
radar.Prf_hz         = 1/radar.Pulse_Width_s;
radar.N_pulses       = 128;
radar.Fs_hz          = 17e6;

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
target.Plat_Vel_m_s = 9.58; % Usain Bolts World record in Velocity falls within the range of our radar
target_doppler_freq_hz = (2*target.Plat_Vel_m_s)/radar.Lambda_m;
fprintf(1,'Target Name \n\tUsain Bolt \n');
fprintf(1,'Target Range  \n\t%2.2f m \n',target.Plat_Pos_m);
fprintf(1,'Target Velocity  \n\t%2.2f m\n',target.Plat_Vel_m_s);
fprintf(1,'Target Doppler Frequency \n\t%2.2f Hz\n\n',target_doppler_freq_hz);


%% FMCW Waveform Generation

% Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.

% Define/get radar parameters needed for sim
fc              = radar.Freq_Center_hz;
maxRange        = 22.5;

% print important radar parameters 
fprintf(1,'Radar Max Range         \n\t%0.2f meters \n',maxRange);
fprintf(1,'Radar Center Frequency  \n\t%2.2f GHz \n',radar.Freq_Center_hz/1e9);
fprintf(1,'Radar Sampling Rate  \n\t%2.2f MHz \n',radar.Fs_hz/1e6);
fprintf(1,'Radar Chirp Duration \n\t%2.1f us \n',radar.Pulse_Width_s*1e6);
fprintf(1,'Radar Bandwidth      \n\t%2.2f MHz\n',radar.Bandwidth_hz/1e6);
fprintf(1,'Radar Pulse Repitition frequency \n\t%2.2f KHz \n',radar.Prf_hz/1e3);
fprintf(1,'Radar Pulses \n\t%2.2f  \n',radar.N_pulses);

% Calculate range resolution
range_resolution = bw2rangeres(radar.Bandwidth_hz);
fprintf(1,'Radar Range Resolution \n\t%2.2f m\n',range_resolution);

% Get operational parameters from radar to use in tx and rx processing
Bandwidth = radar.Bandwidth_hz;
Tchirp = radar.Pulse_Width_s;
slope = Bandwidth / Tchirp;

% Get the number of chirps in one sequence. Its ideal to have 2^ value for the 
% ease of running the FFT  for Doppler Estimation. 

% Get #of doppler cells OR # number of chirps
Nd = radar.N_pulses;         

% Get the number of samples on each chirp. 
n_samples_per_chirp = round(radar.Fs_hz/radar.Prf_hz);

% Get # of range cells
Nr = n_samples_per_chirp;    

% Calcuate timestamp for running the displacement scenario for every sample
% on each chirp
total_samples_cpi   = Nr * Nd;
total_time_all_pris = Nd * Tchirp;

% Total time for samples, generate a linearly spaced vector between 0 and 
% the sum of all PRI's. The number of points in the vector is equal to the 
% to the total number of samples in a CPI. 
time = linspace(0,total_time_all_pris,total_samples_cpi); 

% Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(time));    % transmitted signal, represents the signal that leaves the antenna
Rx=zeros(1,length(time));    % received signal, represents the echo from a target
Mix = zeros(1,length(time)); % beat signal, produced by mixing rx signal echo's with tx signal

% Similar vectors for range_covered and time delay.
range_slow_time = zeros(1,length(time)); % represents a targets dipslacement with respect to the range axis
time_delay      = zeros(1,length(time)); % represents total time delay as a function of a targets range

%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 

for i=1:length(time)         
    % For each time step update the Range of the Target for constant velocity. 
    
    % First calculate range time delay for simulating a targets displacement with
    % respect to the range time axis
    range_slow_time(i) = target.Plat_Pos_m + (time(i) * target.Plat_Vel_m_s);
    time_delay(i)      = 2 * range_slow_time(i) / lightspeed;
    
    % Next we need update the transmitted and received signal time sample
    Tx(i) = exp(  1j* 2 * pi * ( fc * time(i) + slope * time(i)^2 /2 ) );
    Rx(i) = exp( -1j* 2 * pi * ( fc * (time(i) - time_delay(i)) + ( slope * ( time(i) - time_delay(i) )^2) / 2 ) );
    
    % Now we create the beat signal by mixing the transmit and receive. This
    % is done by an element wise matrix multiplication of transmit and receiver signal
    Mix(i) = Tx(i) * Rx(i);
end


%% RANGE MEASUREMENT
% Reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
% Range and Doppler FFT sizes respectively.
Mix = reshape(Mix, [Nr, Nd]);

% Run the FFT on the beat signal along the range bins dimension (Nr) and
% normalize.
Mix_fft = fft(Mix, [], 1);
Mix_fft = (Mix_fft - min(Mix_fft, [], 1)) ./ (max(Mix_fft, [], 1) - min(Mix_fft, [], 1));

% Take the absolute value of FFT output to get the magnitude of the signal
Mix_fft = abs(Mix_fft);

% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Therefore we throw out half of the samples.
Mix_fft = Mix_fft(1:Nr/2,:);

% Plot the range to the target
figure (1)
subplot(2,1,1)

% plot FFT output
first_chirp = 1;
plot(Mix_fft(:,first_chirp))
title('Range from First FFT (Chirp #1)')
xlabel('Range (m)')
ylabel('Amplitude')
axis ([0 (maxRange + 20) 0 1]);

subplot(2,1,2)
last_chirp = Mix_fft(:,radar.N_pulses);
plot(last_chirp)
title('Range from Last FFT (Chirp #128)')
xlabel('Range (m)')
ylabel('Amplitude')
axis ([0 (maxRange + 20) 0 1]);

%% Apply a window to the time domain signal to reduce spectral leakage
% Choose a Window Function
win_dop = kaiser(size(Mix, 1),20); 
win_rng = kaiser(size(Mix, 2),20).';
% Apply the Window to the Doppler Dimension
Mix = win_dop .* Mix .* win_rng;
% Now, beat_signal contains your signal with the window applied to the Doppler & Range dimension

%% RANGE DOPPLER RESPONSE
% A 2DFFT will be run on the mixed signal (beat signal) output to generate
% a range doppler map.

% Range Doppler Map Generation.
% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

% 2D FFT using the FFT size for both dimensions.
sig_rng_dopp_freq = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_rng_dopp_freq = sig_rng_dopp_freq(1:Nr/2,1:Nd);
sig_rng_dopp_freq = fftshift(sig_rng_dopp_freq);
RDM = abs(sig_rng_dopp_freq);
RDM = 10*log10(RDM) ;

% Use the surf function to plot the output of 2DFFT and to show axis in both
% dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure(2)
ax1 = subplot(1, 2, 1);
surfc((doppler_axis),range_axis,RDM);
title( 'RDM From 2D FFT');
xlabel('Velocity');
ylabel('Range');
zlabel('Amplitude (dBFs)');
colorbar;

%% Apply CFAR-CA to get detections

cfar_signal = cfar_2d_rdm_sim(Rdm=RDM, ...
    Pfa=pfa, ...
    NumRangeCells=Nr, ...
    NumDoppCells=Nd, ...
    dopplerAxis=doppler_axis, ...
    rangeAxis=range_axis, ...
    Tr=training_cells_range,...
    Td=training_cells_doppler,...
    Gd=gaurd_cells_range,...
    Gr=gaurd_cells_doppler,...   
    PlotData="false");

ax2 = subplot(1, 2, 2);
surf( range_axis, (doppler_axis), cfar_signal.', 'LineStyle', 'none');
alpha 0.75;
grid minor;
ylabel('velocity [m/s]');
xlabel('range [m]');
zlabel('signal strength [dBFs]')
title(sprintf('CA-CFAR filtered Range Doppler Response (Pfa=%d )', pfa))
colorbar;
colormap jet
axis xy


