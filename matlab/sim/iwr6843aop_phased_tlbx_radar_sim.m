%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Phased Array Toolbox
% Millimeter Wave Radar Target Generation and Detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
clc;

%% IWR68843AOP Medium Range Radar(MRR) Specifications
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 60GHz
% Max Range = 125m
% Range Resolution = 1 m
% Max Velocity = 62 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define simulation constants
lightspeed = physconst('LightSpeed');
%% Define Radar parameters
radar = Radar();
radar.Freq_Center_hz = 60e9;
radar.Bandwidth_hz   = 135e6;
radar.Chirp_Duration_us  = 45e-6;
radar.Lambda_m       = lightspeed/radar.Freq_Center_hz; % Wavelength (m)
radar.Prf_hz         = 1/radar.Chirp_Duration_us;
radar.N_Chirps       = 128;
radar.Fs_hz          = 16e6;

fprintf(1,'Radar Center Frequency  \n\t%2.2f GHz \n',radar.Freq_Center_hz/1e9);
fprintf(1,'Radar Sampling Rate  \n\t%2.2f MHz \n',radar.Fs_hz/1e6);
fprintf(1,'Radar Chirp Duration \n\t%2.1f us \n',radar.Chirp_Duration_us*1e6);
fprintf(1,'Radar Bandwidth      \n\t%2.2f MHz\n',radar.Bandwidth_hz/1e6);
fprintf(1,'Radar Pulse Repitition frequency \n\t%2.2f KHz \n',radar.Prf_hz/1e3);
fprintf(1,'Radar Pulses \n\t%2.2f  \n',radar.N_Chirps);

% Calculate range resolution
range_resolution = lightspeed/(2*radar.Bandwidth_hz);
fprintf(1,'Radar Range Resolution \n\t%2.2f m\n',range_resolution);

%% Define Range and Velocity of target
% Define the target's initial position and velocity. Note : Velocity
% remains contant in this sim
target = Target();
target.Plat_Pos_m   = 10;
target.Plat_Vel_m_s = 9.58;
target_doppler_freq_hz = (2*target.Plat_Vel_m_s)/radar.Lambda_m;
fprintf(1,'Target Name \n\tUsain Bolt \n');
fprintf(1,'Target Range  \n\t%2.2f m \n',target.Plat_Pos_m);
fprintf(1,'Target Velocity  \n\t%2.2f m\n',target.Plat_Vel_m_s);
fprintf(1,'Target Doppler Frequency \n\t%2.2f Hz\n',target_doppler_freq_hz);


%% FMCW Waveform Generation
% define waveform properties
fc     = radar.Freq_Center_hz;
c      = physconst('LightSpeed');
lambda = radar.Lambda_m;

% The sweep time can be computed based on the time needed for the signal to
% travel the unambiguous maximum range. In general, for an FMCW radar system,
% the sweep time should be at least five to six times the round trip time.
% This example uses a factor of 5.5.
range_max = 125;
tm = radar.Chirp_Duration_us;

% The sweep bandwidth can be determined according to the range resolution
% and the sweep slope is calculated using both sweep bandwidth and sweep time.
bw = radar.Bandwidth_hz;
sweep_slope = bw/tm;

% Because an FMCW signal often occupies a large bandwidth, setting the
% sample rate blindly to twice the bandwidth often stresses the capability
% of A/D converter hardware. To address this issue, you can often choose a
% lower sample rate. Consider two things here:

% For a complex sampled signal, the sample rate can be set to the same as the bandwidth.
% FMCW radars estimate the target range using the beat frequency embedded
% in the dechirped signal. The maximum beat frequency the radar needs to
% detect is the sum of the beat frequency corresponding to the maximum range
% and the maximum Doppler frequency. Hence, the sample rate only needs to
% be twice the maximum beat frequency.
%
% In this example, the beat frequency corresponding to the maximum range
% is as follows:
fr_max = range2beat(range_max,sweep_slope,c);

% Because the maximum speed of a person walking is about 0.5 m/h. Hence the
% maximum Doppler shift and the maximum beat frequency can be computed as:
v_max_m  = 50;
fd_max = speed2dop(2*v_max_m,lambda);
fb_max = fr_max + fd_max;

% This example adopts a sample rate of the larger of twice the maximum beat
% frequency and the bandwidth.
fs = radar.Fs_hz;

% With this information, set up the FMCW waveform used in the radar system.
waveform = phased.FMCWWaveform('SweepTime',tm,'SweepBandwidth',bw, ...
    'SampleRate',fs);

% This is an up-sweep linear FMCW signal, often referred to as a sawtooth
% shape. Examine the time-frequency plot of the generated signal.
sig = waveform();
subplot(211); plot(0:1/fs:tm-1/fs,real(sig));
xlabel('Time (s)'); ylabel('Amplitude (v)');
title('FMCW signal'); axis tight;
subplot(212); spectrogram(sig,32,16,32,fs,'yaxis');
title('FMCW signal spectrogram');

person_dist    = target.Plat_Pos_m;
person_speed   = target.Plat_Vel_m_s;
person_avg_rcs = min(10*log10(person_dist),0.1);
person_rcs     = db2pow(person_avg_rcs);
% person_target  = phased.RadarTarget('MeanRCS',person_rcs,'PropagationSpeed',c,...
%     'OperatingFrequency',fc);
% person_motion = phased.Platform('InitialPosition',[person_dist;0;0.5],...
%     'Velocity',[person_speed;0;0]);
Numtgts = 2;
tgtpos = zeros(3,Numtgts);
tgtvel = zeros(3,Numtgts);
tgtpos(1,:) = [30 10];
tgtvel(1,:) = [9 5];
tgtrcs = db2pow(10)*[1 1];
person_motion = phased.Platform(tgtpos,tgtvel);
person_target  = phased.RadarTarget('MeanRCS',tgtrcs,'PropagationSpeed',c,...
    'OperatingFrequency',fc);

% Assume the propagation model to be free space.
channel = phased.FreeSpace('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs,'TwoWayPropagation',true);

% Radar system includes the transmitter, the receiver, and the antenna.
% Note that this example models only main components and omits the effect
% from other components, such as coupler and mixer. In addition, for the
% sake of simplicity, the antenna is assumed to be isotropic and the gain
% of the antenna is included in the transmitter and the receiver.
ant_aperture = (.0045)^2;                       % Antenna aperture (m^2)
ant_gain = aperture2gain(ant_aperture,lambda);  % Antenna gain (dB)

tx_power = db2pow(10);                     % in watts
tx_gain   = 9+ant_gain;                     % in dB

rx_gain   = 15+ant_gain;                    % in dB
rx_nf     = 4.5;                            % in dB

transmitter = phased.Transmitter('PeakPower',tx_power,'Gain',tx_gain);
receiver = phased.ReceiverPreamp('Gain',rx_gain,'NoiseFigure',rx_nf,...
    'SampleRate',fs);

radar_speed = 0;
radarmotion = phased.Platform('InitialPosition',[0;0;0.5],...
    'Velocity',[radar_speed;0;0]);

%% Radar Signal Simulation
% As briefly mentioned in earlier sections, an FMCW radar measures the range
% by examining the beat frequency in the dechirped signal. To extract this
% frequency, a dechirp operation is performed by mixing the received signal
% with the transmitted signal. After the mixing, the dechirped signal
% contains only individual frequency components that correspond to the target range.
%
% In addition, even though it is possible to extract the Doppler information
% from a single sweep, the Doppler shift is often extracted among several
% sweeps because within one pulse, the Doppler frequency is indistinguishable
% from the beat frequency. To measure the range and Doppler, an FMCW radar
% typically performs the following operations:
%
% 1.The waveform generator generates the FMCW signal.
%
% 2.The transmitter and the antenna amplify the signal and radiate the signal
% into space.
%
% 3.The signal propagates to the target, gets reflected by the target, and
% travels back to the radar.
%
% 4.The receiving antenna collects the signal.
%
% 5.The received signal is dechirped and saved in a buffer.
%
% 6.Once a certain number of sweeps fill the buffer, the Fourier transform is
% performed in both range and Doppler to extract the beat frequency as well
% as the Doppler shift. can then estimate the range and speed of the target
% using these results. Range and Doppler can also be shown as an image and
% give an intuitive indication of where the target is in the range and speed domain.
%
% The next section simulates the process outlined above.
%
% During the simulation, a spectrum analyzer is used to show the spectrum
% of each received sweep as well as its dechirped counterpart.
specanalyzer = spectrumAnalyzer('SampleRate',fs, ...
    'Method','welch','AveragingMethod','running', ...
    'PlotAsTwoSidedSpectrum',true, 'FrequencyResolutionMethod','rbw', ...
    'Title','Spectrum for received and dechirped signal', ...
    'ShowLegend',true);

% Next run the simulation loop
rng(2012);
Nsweep = radar.N_Chirps;
xr = complex(zeros(waveform.SampleRate*waveform.SweepTime,Nsweep));
%% Define a Uniform Linear Array (ULA) as the Transmitting Antenna
antennaArray = phased.ULA('NumElements', 2, 'ElementSpacing', 0.5*c/fc);

%% Create a Radiator Object
radiator = phased.Radiator('Sensor', antennaArray, ...
    'OperatingFrequency', fc, ...
    'PropagationSpeed', c, ...
    'CombineRadiatedSignals', true);
collector = phased.Collector('Sensor', antennaArray, ...
    'OperatingFrequency', fc, ...
    'PropagationSpeed', c, ...
    'Wavefront', 'Plane');

for n = 1:Nsweep
    % Update radar and target positions
    [radar_pos,radar_vel] = radarmotion(waveform.SweepTime);
    [tgt_pos,tgt_vel] = person_motion(1/radar.Prf_hz);
    [tgtrng,tgtang] = rangeangle(tgtpos);

    % Transmit FMCW waveform
    sig = waveform();
    txsig = transmitter(sig);

    % Add a radiate to capture all targets for this signal
    txsig = radiator(txsig,tgtang);

    % Propagate the signal and reflect off the target
    txsig = channel(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel);
    txsig = person_target(txsig);

    % Dechirp the received radar return
    rxcol = collector(txsig,tgtang);
    rxsig = receiver(rxcol);
    dechirpsig = dechirp(rxsig,sig);

    % Visualize the spectrum
    specanalyzer([rxsig dechirpsig]);

    xr(:,n) = dechirpsig;
end

rngdopresp = phased.RangeDopplerResponse('PropagationSpeed',c,...
    'DopplerOutput','Speed','OperatingFrequency',fc,'SampleRate',fs,...
    'RangeMethod','FFT','SweepSlope',sweep_slope,...
    'RangeFFTLengthSource','Property','RangeFFTLength',2048,...
    'DopplerFFTLengthSource','Property','DopplerFFTLength',256,RangeWindow='Chebyshev',DopplerWindow='Chebyshev');

clf;
plotResponse(rngdopresp,xr);
axis([-v_max_m v_max_m 0 range_max])
climVals = clim;

% As a side note, although the received signal is sampled at high frequency so the
% system can achieve the required range resolution, after the dechirp, you
% need to sample it only at a rate that corresponds to the maximum beat
% frequency. Since the maximum beat frequency is in general less than the
% required sweeping bandwidth, the signal can be decimated to alleviate the
% hardware cost. The following code shows the decimation process:
Dn = fix(fs/(2*fb_max));
for m = size(xr,2):-1:1
    xr_d(:,m) = decimate(xr(:,m),Dn,'FIR');
end
fs_d = fs/Dn;

%% Range Estimate
% First estimate the beat frequency using the coherently integrated sweeps
% and then converted to the range.
fb_rng = rootmusic(pulsint(xr_d,'coherent'),1,fs_d);
rng_est = beat2range(fb_rng,sweep_slope,c);
fprintf(1,'Range Estimate \n\t%2.2f m\n',rng_est);

%% Doppler Estimate
% Second, estimate the Doppler shift across the sweeps at the range where
% the target is present.
peak_loc = val2ind(rng_est,c/(fs_d*2));
fd = -rootmusic(xr_d(peak_loc,:),1,1/tm);
v_est = dop2speed(fd,lambda)/2;
fprintf(1,'Doppler Estimate \n\t%2.2f m/s\n',v_est);

%% Range Doppler Coupling Effect
% One issue associated with linear FM signals, such as an FMCW signal, is
% the range Doppler coupling effect. As discussed earlier, the target range
% corresponds to the beat frequency. Hence, an accurate range estimation
% depends on an accurate estimate of beat frequency. However, the presence
% of Doppler shift changes the beat frequency, resulting in a biased range estimation.

% For the situation outlined in this example, the range error caused by the
% relative speed between the target and the radar is as follows:
deltaR = rdcoupling(fd,sweep_slope,c);
fprintf(1,'Range Doppler Coupling \n\t%2.2f \n',deltaR);

%% Unambiguous velocity calcuation
v_unambiguous = dop2speed(1/(2*tm),lambda)/2;
fprintf(1,'Unambiguous velocity \n\t%2.2f Hz\n',v_unambiguous);