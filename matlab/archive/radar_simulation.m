
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Millimeter Wave Radar Target Generation and Detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear last_chirp
clc;

%% IWR68843AOP Medium Range Radar(MRR) Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 60GHz
% Max Range = 125m
% Range Resolution = 0.1 m
% Max Velocity = 62 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define simulation constants
lightspeed = physconst('LightSpeed');

%% Define Range and Velocity of target
% Define the target's initial position and velocity. Note : Velocity
% remains contant in this sim
target = Target();
target.Plat_Pos_m   = 20;
target.Plat_Vel_m_s = 10;

%% Define Radar parameters
radar = Radar();
radar.Freq_Center_hz = 60e9;
radar.Bandwidth_hz   = 135e6;
radar.Pulse_Width_s  = 7e-6;
radar.Lambda_m       = freq2wavelen(radar.Freq_Center_hz,lightspeed); % Wavelength (m)
radar.Prf_hz         = 1/radar.Pulse_Width_s;
radar.N_pulses       = 128;
radar.Fs_hz          = 16e6;

%% FMCW Waveform Generation

% Design the FMCW waveform by giving the specs of each of its parameters.
% Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
% chirp using the requirements above.

% Define/get radar parameters needed for sim
fc              = radar.Freq_Center_hz;
maxRange        = 125;

% Calculate range resolution
range_resolution = bw2rangeres(radar.Bandwidth_hz);
fprintf(1,'Range Resolution \n\t%2.2f m\n',range_resolution);

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

% Putput of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Thereforee we throw out half of the samples.
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

%% RANGE DOPPLER RESPONSE
% A 2DFFT will be run on the mixed signal (beat signal) output to generate
% a range doppler map.

% Range Doppler Map Generation.
% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.
Mix = reshape(Mix,[Nr,Nd]);

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
surf(doppler_axis,range_axis,RDM);
title( 'RDM From 2D FFT');
xlabel('Velocity');
ylabel('Range');
zlabel('Amplitude (dB)');
colorbar;

% %% CFAR implementation
% 
% %Slide Window through the complete Range Doppler Map
% 
% % *%TODO* :
% %Select the number of Training Cells in both the dimensions.
% rangeTrainingCells = 10;
% dopplerTrainingCells = 8;
% 
% % *%TODO* :
% %Select the number of Guard Cells in both dimensions around the Cell under 
% %test (CUT) for accurate estimation
% rangeGuardCells = 2;
% dopplerGuardCells = 4;
% 
% guardAndCUT_Cells = (2*rangeGuardCells+1)*(2*dopplerGuardCells+1);
% trainingCells = (2*rangeTrainingCells+2*rangeGuardCells+1)*(2*dopplerTrainingCells+2*dopplerGuardCells+1) - guardAndCUT_Cells;
% 
% % *%TODO* :
% % offset the threshold by SNR value in dB
% offset = 10;
% 
% % *%TODO* :
% %Create a vector to store noise_level for each iteration on training cells
% noise_level = zeros(Nr/2,Nd);
% 
% %A vector to store signal after applying CA_CFAR
% signal_cfar = zeros(Nr/2,Nd);
% 
% % *%TODO* :
% %design a loop such that it slides the CUT across range doppler map by
% %giving margins at the edges for Training and Guard Cells.
% %For every iteration sum the signal level within all the training
% %cells. To sum convert the value from logarithmic to linear using db2pow
% %function. Average the summed values for all of the training
% %cells used. After averaging convert it back to logarithimic using pow2db.
% %Further add the offset to it to determine the threshold. Next, compare the
% %signal under CUT with this threshold. If the CUT level > threshold assign
% %it a value of 1, else equate it to 0.
% for r = 1:(Nr/2-(2*rangeGuardCells+2*rangeTrainingCells))
%    for d = 1:(Nd-(2*dopplerGuardCells+2*dopplerTrainingCells))
%    % Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
%    % CFAR
% 
%    % CUT index
%    CUT_r = r+rangeGuardCells+rangeTrainingCells+1;
%    CUT_d = d+dopplerGuardCells+dopplerTrainingCells+1;
% 
%    noise = sum(sum(db2pow(RDM(r:r+2*rangeGuardCells+2*rangeTrainingCells,d:d+2*dopplerGuardCells+2*dopplerTrainingCells))));
%    noise = noise - sum(sum(db2pow(RDM(r+rangeTrainingCells:r+rangeTrainingCells+2*rangeGuardCells,d+dopplerTrainingCells:d+dopplerTrainingCells+2*dopplerGuardCells))));
%    noise_level(CUT_r, CUT_d) = pow2db(noise/trainingCells) + offset;
% 
%    %Compare the original signal with the noise threshold
%    if RDM(CUT_r, CUT_d) > noise_level(CUT_r, CUT_d)
%        signal_cfar(CUT_r, CUT_d) = 1;
%    end
%    end
% end
% 
% % *%TODO* :
% % The process above will generate a thresholded block, which is smaller 
% %than the Range Doppler Map as the CUT cannot be located at the edges of
% %matrix. Hence,few cells will not be thresholded. To keep the map size same
% % set those values to 0. 
% 
% % Already accounted for this error in my algorithm above!
% 
% 
% % *%TODO* :
% %display the CFAR output using the Surf function like we did for Range
% %Doppler Response output.
% figure('Name', 'CA-CFAR Filtered RDM')
% surf(doppler_axis,range_axis,signal_cfar);
% % surf(doppler_axis,range_axis,noise_level);
% title( 'CA-CFAR Filtered RDM');
% xlabel('Velocity');
% ylabel('Range');
% zlabel('Normalized Amplitude');
% colorbar;
% 
% %display the noise threshold using CA-CFAR for for Range
% %Doppler Response output.
% figure('Name', 'Noise threshold using CA-CFAR for RDM')
% surf(doppler_axis,range_axis,noise_level);
% title( 'Noise threshold');
% xlabel('Velocity');
% ylabel('Range');
% zlabel('Normalized Amplitude');
% colorbar;