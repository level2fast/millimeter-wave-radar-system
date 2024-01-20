%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radar Target Generation and Detection Simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize radar and target parameters
range_resolution = 1;
max_range = 100;
lightspeed = physconst('LightSpeed');

target = Target();
target.Plat_Pos_m = 10;
target.Plat_Vel_m_s = 3;

radar = Radar();
radar.Freq_Center_hz = 77e9;
radar.Bandwidth_hz   = lightspeed/(2*range_resolution);
radar.Pulse_Width_s  = (5.5 * 2 * max_range) / lightspeed;
radar.Lambda_m       = lightspeed/radar.Freq_Center_hz;


% calculate other params needed for data processing
target_doppler_freq_hz = (2*target.Plat_Vel_m_s)/radar.Lambda_m;
fprintf(1,'Target Doppler Frequency \n\t%2.2f Hz\n',target_doppler_freq_hz);
slope = radar.Bandwidth_hz / radar.Pulse_Width_s;

%The number of chirps in one sequence. Its ideal to have 2^n value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
time=linspace(0,Nd*radar.Pulse_Width_s,Nr*Nd); %total time for samples

%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(time)); %transmitted signal
Rx=zeros(1,length(time)); %received signal
Mix = zeros(1,length(time)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(time));
time_delay=zeros(1,length(time));

%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 
for i=1:length(time)         
    %For each time stamp update the Range of the Target for constant velocity. 
    r_t(i) = target.Plat_Pos_m + time(i)*target.Plat_Vel_m_s;
    time_delay(i) = 2*r_t(i) / lightspeed;
    
    %For each time sample we need update the transmitted and
    %received signal. 
    Tx(i) = cos( 2 * pi * ( radar.Freq_Center_hz * time(i) + slope * time(i)^2 /2 ) );
    Rx(i) = cos( 2 * pi * ( radar.Freq_Center_hz * (time(i) - time_delay(i)) + ( slope * ( time(i) - time_delay(i) )^2) / 2 ) );
    
    %Now by mixing the Transmit and Receive generate the beat signal
    %This is done by element wise matrix multiplication of Transmit and
    %Receiver Signal
    Mix(i) = Tx(i) * Rx(i);
end

%% RANGE MEASUREMENT
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
Mix = reshape(Mix, [Nr, Nd]);

%run the FFT on the beat signal along the range bins dimension (Nr) and
%normalize.
Mix_fft = fft(Mix, [], 1);
Mix_fft = (Mix_fft - min(Mix_fft, [], 1)) ./ (max(Mix_fft, [], 1) - min(Mix_fft, [], 1));

% Take the absolute value of FFT output
Mix_fft = abs(Mix_fft);

% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.
Mix_fft = Mix_fft(1:Nr/2,:);

%plotting the range
figure (2)
subplot(2,1,1)

% plot FFT output
plot(Mix_fft(:,1))
title('Range from First FFT (Chirp #1)')
xlabel('Range (m)')
ylabel('Amplitude')
axis ([0 200 0 1]);

subplot(2,1,2)

% plot FFT output
plot(Mix_fft(:,128))
title('Range from First FFT (Chirp #128)')
xlabel('Range (m)')
ylabel('Amplitude')
axis ([0 200 0 1]);

%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM

% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift(sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis   = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure(3)
surf(doppler_axis,range_axis,RDM);
title( 'RDM From 2D FFT');
xlabel('Velocity');
ylabel('Range');
zlabel('Amplitude (dB)');
colorbar;

