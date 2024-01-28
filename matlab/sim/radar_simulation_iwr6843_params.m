%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radar Target Generation and Detection Simulator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize radar aradar.N_pulses target parameters
c = physconst('LightSpeed');

radar = Radar();
radar.Freq_Center_hz = 60e9;
radar.Bandwidth_hz   = 540e6;
radar.Pulse_Width_s  = 45e-6;
radar.Lambda_m       = freq2wavelen(radar.Freq_Center_hz,c); % Wavelength (m)
radar.Prf_hz         = 1/radar.Pulse_Width_s;
radar.N_pulses       = 128;
radar.Fs_hz          = 11e6;
pri                  = radar.Pulse_Width_s;

% Use phased.RangEstimator object to generate RDM

% Setup scenario parameters by creating our targets
fc = radar.Freq_Center_hz;
Numtgts = 3;
tgtpos = zeros(Numtgts);
tgtpos(1,:) = [100 30 10];
tgtvel = zeros(3,Numtgts);
tgtvel(1,:) = [-40 10 5];
tgtrcs = db2pow(10)*[1 1 0];
tgtmotion = phased.Platform(tgtpos,tgtvel);
target = phased.RadarTarget('PropagationSpeed',c,'OperatingFrequency',fc, ...
    'MeanRCS',tgtrcs);
radarpos = [0;0;0];
radarvel = [0;0;0];
radarmotion = phased.Platform(radarpos,radarvel);

% create tx and rx antennas
txantenna = phased.IsotropicAntennaElement;
rxantenna = clone(txantenna);

% Setup transmitter-end signal processing
fs = radar.Fs_hz;
bw = radar.Bandwidth_hz;
prf = radar.Prf_hz;
pulses = 1;
duty_cycle_perc = 0.2;
waveform = phased.LinearFMWaveform('SampleRate',fs, ...
    'PRF',prf,'OutputFormat','Pulses','NumPulses',pulses,'SweepBandwidth',bw, ...
    'DurationSpecification','Duty cycle','DutyCycle',duty_cycle_perc);
sig = waveform();
Nr = length(sig);
bwrms = bandwidth(waveform)/sqrt(12);
rngrms = c/bwrms;

% setup transmitter and radiator
peakpower = 10;
txgain = 36.0;
transmitter = phased.Transmitter( ...
    'PeakPower',peakpower, ...
    'Gain',txgain, ...
    'InUseOutputPort',true);
radiator = phased.Radiator( ...
    'Sensor',txantenna,...
    'PropagationSpeed',c,...
    'OperatingFrequency',fc);

% setup free space channel
channel = phased.FreeSpace( ...
    'SampleRate',fs, ...    
    'PropagationSpeed',c, ...
    'OperatingFrequency',fc, ...
    'TwoWayPropagation',true);

% setup receiver
collector = phased.Collector( ...
    'Sensor',rxantenna, ...
    'PropagationSpeed',c, ...
    'OperatingFrequency',fc);
rxgain = 42.0;
noisefig = 1;
receiver = phased.ReceiverPreamp( ...
    'SampleRate',fs, ...
    'Gain',rxgain, ...
    'NoiseFigure',noisefig);

% Loop over the pulses to create a data cube of 128 pulses. For each step 
% of the loop, move the target and propagate the signal. Then put the received 
% signal into the data cube. The data cube contains the received signal per 
% pulse. Ordinarily, a data cube has three dimensions where the last dimension 
% corresponds to antennas or beams. Because only one sensor is used, the cube 
% has only two dimensions.
% 
% The processing steps are:
% 
% Move the radar and targets.
% 
% Transmit a waveform.
% 
% Propagate the waveform signal to the target.
% 
% Reflect the signal from the target.
% 
% Propagate the waveform back to the radar. Two-way propagation enables you to combine the return propagation with the outbound propagation.
% 
% Receive the signal at the radar.
% 
% Load the signal into the data cube.
n_samples_per_pulse = radar.Pulse_Width_s * radar.Fs_hz;
Np = radar.N_pulses;
dt = pri;
cube = zeros(Nr,Np);
for n = 1:Np
    [sensorpos,sensorvel] = radarmotion(dt);
    [tgtpos,tgtvel] = tgtmotion(dt);
    [~,tgtang] = rangeangle(tgtpos,sensorpos);
    sig = waveform();
    [txsig,txstatus] = transmitter(sig);
    txsig = radiator(txsig,tgtang);
    txsig = channel(txsig,sensorpos,tgtpos,sensorvel,tgtvel);    
    tgtsig = target(txsig);   
    rxcol = collector(tgtsig,tgtang);
    rxsig = receiver(rxcol);
    cube(:,n) = rxsig;
end

% % display data cube showing signals per pulse
% imagesc((0:(Np-1))*pri*1e6,(0:(Nr-1))/fs*1e6,abs(cube))
% xlabel('Slow Time {\mu}s')
% ylabel('Fast Time {\mu}s')
% axis xy

% show range doppler map
ndop = 512;
rangedopresp = phased.RangeDopplerResponse('SampleRate',fs, ...
    'PropagationSpeed',c,'DopplerFFTLengthSource','Property', ...
    'DopplerFFTLength',ndop,'DopplerOutput','Speed', ...
    'OperatingFrequency',fc);
matchingcoeff = getMatchedFilter(waveform);
[rngdopresp,rnggrid,dopgrid] = rangedopresp(cube,matchingcoeff);
imagesc(dopgrid,rnggrid,10*log10(abs(rngdopresp)))
colorbar
xlabel('Closing Speed (m/s)')
ylabel('Range (m)')
axis xy

figure(2)
surf(dopgrid,rnggrid,10*log10(abs(rngdopresp)));
title( 'RDM From 2D FFT');
xlabel('Velocity');
ylabel('Range');
zlabel('Amplitude (dB)');
colorbar;

mfgain = matchingcoeff'*matchingcoeff;
dopgain = Np;
noisebw = fs;
noisepower = noisepow(noisebw,receiver.NoiseFigure,receiver.ReferenceTemperature);
noisepowerprc = mfgain*dopgain*noisepower;
noise = noisepowerprc*ones(size(rngdopresp));

rangeestimator = phased.RangeEstimator('NumEstimatesSource','Auto', ...
    'VarianceOutputPort',true,'NoisePowerSource','Input port', ...
    'RMSResolution',rngrms);
dopestimator = phased.DopplerEstimator('VarianceOutputPort',true, ...
    'NoisePowerSource','Input port','NumPulses',Np);

detidx = NaN(2,Numtgts);
tgtrng = rangeangle(tgtpos,radarpos);
tgtspd = radialspeed(tgtpos,tgtvel,radarpos,radarvel);
tgtdop = 2*speed2dop(tgtspd,c/fc);
for m = 1:numel(tgtrng)
    [~,iMin] = min(abs(rnggrid-tgtrng(m)));
    detidx(1,m) = iMin;
    [~,iMin] = min(abs(dopgrid-tgtspd(m)));
    detidx(2,m) = iMin;
end

ind = sub2ind(size(noise),detidx(1,:),detidx(2,:));

[rngest,rngvar] = rangeestimator(rngdopresp,rnggrid,detidx,noise(ind));

[spdest,spdvar] = dopestimator(rngdopresp,dopgrid,detidx,noise(ind));