%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radar Target Generation aradar.N_pulses Detection Simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot_results_chirp = 0;
% Initialize radar aradar.N_pulses target parameters
range_resolution = 1;
max_range = 10;
lightspeed = physconst('LightSpeed');

target = Target();
target.Plat_Pos_m = 100;
target.Plat_Vel_m_s = 0;

radar = Radar();
radar.Freq_Center_hz = 60e9;
radar.Bandwidth_hz   = 2e6;
radar.Pulse_Width_s  = 50e-6;
radar.Lambda_m       = freq2wavelen(radar.Freq_Center_hz,lightspeed); % Wavelength (m)
radar.Prf_hz         = 10e3;
radar.N_pulses       = 128;
radar.Fs_hz          = 5e6;

% calculate aradar.N_pulses display targets absolute doppler frequency
target_doppler_freq_hz = (2*target.Plat_Vel_m_s)/radar.Lambda_m;
fprintf(1,'Target Doppler Frequency \n\t%2.2f Hz\n',target_doppler_freq_hz);

% calculate number of samples per pulse in order to generate
% a waveform with the correct number of samples 
n_samples_per_pulse = radar.Pulse_Width_s * radar.Fs_hz;

% generate linear chirp waveform with "n_samples" number of smaples
tx_signal = create_lfm_pulse_samples(SweepBandwidth=radar.Bandwidth_hz,Fs=radar.Fs_hz,NumberOfSamples=n_samples_per_pulse);
%tx_signal = create_lfm_pulse_time(F0=0,F1=radar.Bandwidth_hz,Fs=radar.Fs_hz,T=radar.Pulse_Width_s);
if(plot_results_chirp)
    dt = 1/radar.Fs_hz;
    time_vec_s = 0:dt:radar.Pulse_Width_s-(dt);
    clc;close all;
    figure(1)
    subplot(2,2,1)
    plot(time_vec_s,real(tx_signal),'b')
    hold on
    %plot(imag(tx_signal),'r')
    grid on
    title('Real and Imaginay Parts of Time Series')
    xlabel('Time Index(samples)')
    ylabel('Amplitude')

    x  = tx_signal;
    fs = radar.Fs_hz;
    L=length(tx_signal);
    NFFT = n_samples_per_pulse;
    X = fftshift(fft(x,NFFT));
    f = fs*(-NFFT/2:NFFT/2-1)/NFFT; %Frequency Vector
    subplot(2,2,3)
    plot(f,abs(X)/(L),'r');
    title('Magnitude of FFT');
    xlabel('Frequency (Hz)')
    ylabel('Magnitude |X(f)|');

    X2 = fft(x,NFFT);
    X2 = X2(1:NFFT/2+1);%Throw the samples after NFFT/2 for single sided plot
    Pxx=X2.*conj(X2)/(NFFT*NFFT);
    f2 = fs*(0:NFFT/2)/NFFT; %Frequency Vector
    subplot(2,2,4)
    plot(f2,10*log10(Pxx),'r');
    title('Single Sided - Power Spectral Density');
    xlabel('Frequency (Hz)')
    ylabel('Power Spectral Density- P_{xx} dB/Hz');
    hold off
end

% calcuate the fast time frequency vector which will be used
% for applying the range time delay
fast_time_freq_vec = create_fast_time_freq(NumPulses=radar.N_pulses,NumSampPerPulse=n_samples_per_pulse,SampleRate_Hz=radar.Fs_hz);

% calculate slow time vector
slow_time_vec  = (0:radar.N_pulses-1)/radar.Prf_hz;

% calculate range time delay for simulating a targets displacement with
% respect to the range time axis
range_slow_time_target = target.Plat_Pos_m + (target.Plat_Vel_m_s * slow_time_vec);

time_delay_vec = (2*range_slow_time_target)/lightspeed;

tx_signal_norm = tx_signal(:)/norm(tx_signal(:));
tx_signal_freq = fft(tx_signal_norm,n_samples_per_pulse);

signal_data_mat = zeros(n_samples_per_pulse,radar.N_pulses);

% calculate the phase of the transmitted signal when it is delayed
% in time. This is done so that this phase can be combined with
% the orignal waveform in order to simulate a target at a specific
% range aradar.N_pulses doppler
time_delay_phase = 2 * pi * (fast_time_freq_vec + radar.Freq_Center_hz) * time_delay_vec;

% calculate phase shift vector which we'll use to take advantage of the
% fourier transform shift property. i.e. a linear shift in time is
% equivalent to a change of phase in freq.
phase_shift_vec = exp(-1j * time_delay_phase);

% apply frequency domain phase shift
shifted_signal = phase_shift_vec .* tx_signal_freq;
shifted_signal_time = ifft(shifted_signal);

% create time domain received signal which is needed for match filtering
% step
rx_signal = signal_data_mat + shifted_signal_time;

figure(2)
subplot(2,1,1)
imagesc(20*log10(abs((rx_signal))))
colorbar
title('Fast time vs. Slow time')
xlabel('Pulse');
ylabel('Range Samples');
title('Matched Filter Output')


%% RANGE MEASUREMENT
%tx_signal = repmat(tx_signal,)
match_filter_outptut = compress_signal(tx_signal,rx_signal,1,n_samples_per_pulse);
subplot(2,1,2)
%Plot result to verify matched filter result
plot(abs(fftshift((match_filter_outptut))));
grid on
hold on
xlabel('Samples')
ylabel('Amplitude') 
title('Matched Filter Output')



% title('Range compressed image of first patch')
% xlabel('Range bin');
% ylabel('Azimuth bin');
% title('Matched Filter Output')

hold off

% subplot(2,1,2)
% imagesc(real(match_filter_outptut));
% xlabel('Range (m)')
% ylabel('Amplitude')
% title('Range from First FFT (Chirp #1)')
% 
% subplot(2,1,3)
% 
% % plot FFT output
% plot(match_filter_outptut)
% title('Range from First FFT (Chirp #1)')
% xlabel('Range (m)')
% ylabel('Amplitude')
% axis ([0 200 0 1]);
% 

