%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radar Target Generation and Detection Simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize radar aradar.N_pulses target parameters
c = physconst('LightSpeed');                % Speed of light in air (m/s)

radar = Radar();
radar.Freq_Center_hz = 60e9;
radar.Bandwidth_hz   = 540e6;
radar.Pulse_Width_s  = 45e-6;
radar.Lambda_m       = freq2wavelen(radar.Freq_Center_hz,c); % Wavelength (m)
radar.Prf_hz         = 1/radar.Pulse_Width_s;
radar.N_pulses       = 128;
radar.Fs_hz          = 11e6;
radar.Duty_Factor    = 0.02;
pri                  = radar.Pulse_Width_s;

% Set random number generator for repeatable results
rng(2017);

% Compute hardware parameters from specified long-range requirements
fc = radar.Freq_Center_hz;                  % Center frequency (Hz) 
lambda = radar.Lambda_m;                    % Wavelength (m)

% Set the chirp duration to be 5 times the max range requirement
rangeMax = 125;                             % Maximum range (m)
tm = radar.Pulse_Width_s;                   % Chirp duration (s)

% Determine the waveform bandwidth from the required range resolution
bw = radar.Bandwidth_hz;                    % Corresponding bandwidth (Hz)

% Set the sampling rate to satisfy both the range and velocity requirements
% for the radar
sweepSlope = bw/tm;                           % FMCW sweep slope (Hz/s)
fbeatMax = range2beat(rangeMax,sweepSlope,c); % Maximum beat frequency (Hz)

vMax = 63.75;                                 % Maximum Velocity of cars (m/s)
fdopMax = speed2dop(2*vMax,lambda);           % Maximum Doppler shift (Hz)

fifMax = fbeatMax+fdopMax;   % Maximum received IF (Hz)
fs = radar.Fs_hz;            % Sampling rate (Hz)

% Configure the FMCW waveform using the waveform parameters derived from
% the long-range requirements
waveform = phased.FMCWWaveform('SweepTime',tm,'SweepBandwidth',bw,...
    'SampleRate',fs,'SweepDirection','Up');
if strcmp(waveform.SweepDirection,'Down')
    sweepSlope = -sweepSlope;
end
Nsweep = radar.N_pulses;
sig = waveform();

% Model the antenna element
antElmnt = phased.IsotropicAntennaElement('BackBaffled',true);

% Construct the receive array
Ne = 4;
rxArray = phased.ULA('Element',antElmnt,'NumElements',Ne,...
    'ElementSpacing',lambda/2);

% Half-power beamwidth of the receive array
hpbw = beamwidth(rxArray,fc,'PropagationSpeed',c);

antAperture = (.0045)^2;                      % Antenna aperture (m^2)
antGain = aperture2gain(antAperture,lambda);  % Antenna gain (dB)

txPkPower = db2pow(10);                       % Tx peak power (W)
txGain   = antGain;                             % Tx antenna gain (dB)

rxGain = antGain;                             % Rx antenna gain (dB)
rxNF = 4.5;                                   % Receiver noise figure (dB)

% Waveform transmitter
transmitter = phased.Transmitter('PeakPower',txPkPower,'Gain',txGain);

% Radiator for single transmit element
radiator = phased.Radiator('Sensor',antElmnt,'OperatingFrequency',fc);

% Collector for receive array
collector = phased.Collector('Sensor',rxArray,'OperatingFrequency',fc);

% Receiver preamplifier
receiver = phased.ReceiverPreamp('Gain',rxGain,'NoiseFigure',rxNF,...
    'SampleRate',fs);

% Define radar
radar = radarTransceiver('Waveform',waveform,'Transmitter',transmitter,...
    'TransmitAntenna',radiator,'ReceiveAntenna',collector,'Receiver',receiver);

% Direction-of-arrival estimator for linear phased array signals
doaest = phased.RootMUSICEstimator(...
    'SensorArray',rxArray,...
    'PropagationSpeed',c,'OperatingFrequency',fc,...
    'NumSignalsSource','Property','NumSignals',1);

% Scan beams in front of ego vehicle for range-angle image display
angscan = -60:60;
beamscan = phased.PhaseShiftBeamformer('Direction',[angscan;0*angscan],...
    'SensorArray',rxArray,'OperatingFrequency',fc);

% Form forward-facing beam to detect objects in front of the ego vehicle
beamformer = phased.PhaseShiftBeamformer('SensorArray',rxArray,...
    'PropagationSpeed',c,'OperatingFrequency',fc,'Direction',[0;0]);

Nft = waveform.SweepTime*waveform.SampleRate; % Number of fast-time samples
Nst = Nsweep;                                 % Number of slow-time samples
Nr = 2^nextpow2(Nft);                         % Number of range samples 
Nd = 2^nextpow2(Nst);                         % Number of Doppler samples 
rngdopresp = phased.RangeDopplerResponse('RangeMethod','FFT',...
    'DopplerOutput','Speed','SweepSlope',sweepSlope,...
    'RangeFFTLengthSource','Property','RangeFFTLength',Nr,...
    'RangeWindow','Hann',...
    'DopplerFFTLengthSource','Property','DopplerFFTLength',Nd,...
    'DopplerWindow','Hann',...
    'PropagationSpeed',c,'OperatingFrequency',fc,'SampleRate',fs);

