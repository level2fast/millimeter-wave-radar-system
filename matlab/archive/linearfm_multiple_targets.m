% This program generate the FMCW signal reflected from targets, mainly
% modified from the example of "phased.RangeEstimator System
% object" in matlab 2018b. It need the "Phased Array System Toolbox" to
% work.
clear all;
close all;
fs = 153.6e6;
c = physconst('LightSpeed');
M=256;
fc = c*M;
landa=c/fc;
prf=fs/1000;
pri=1/prf;
Np = 300;
RangeMax=c/2/prf;   %
VelMax=prf/2*landa/2;
DutyCycle=0.02;
Rresolution=c/2/(fs);
Numtgts = 5;
tgtpos = zeros(3,Numtgts);
tgtvel = zeros(3,Numtgts);
tgtpos(1,:) = [1 300 200 100 900];
tgtvel(1,:) = [110 0 -90 -80 60];
tgtrcs = db2pow(10)*[1 1 1 1 1];
tgtmotion = phased.Platform(tgtpos,tgtvel);
target = phased.RadarTarget('PropagationSpeed',c,'OperatingFrequency',fc, ...
    'MeanRCS',tgtrcs);
radarpos = [0;0;0];
radarvel = [0;0;0];
radarmotion = phased.Platform(radarpos,radarvel);
txantenna = phased.IsotropicAntennaElement;
rxantenna = clone(txantenna);
bw = fs/2;
waveform = phased.LinearFMWaveform('SampleRate',fs, ...
    'PRF',prf,'OutputFormat','Pulses','NumPulses',1,'SweepBandwidth',fs/2, ...
    'DurationSpecification','Duty cycle','DutyCycle',DutyCycle);
sig = waveform();
Nr = length(sig);
bwrms = bandwidth(waveform)/sqrt(12);
rngrms = c/bwrms;
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
channel = phased.FreeSpace( ...
    'SampleRate',fs, ...    
    'PropagationSpeed',c, ...
    'OperatingFrequency',fc, ...
    'TwoWayPropagation',true);
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
dt = pri;
cube = zeros(Nr,Np);
for n = 1:Np
    [sensorpos,sensorvel] = radarmotion(dt);
    [tgtpos,tgtvel] = tgtmotion(dt);
    [tgtrng,tgtang] = rangeangle(tgtpos,sensorpos);
    sig = waveform();
    [txsig,txstatus] = transmitter(sig);    
    txsig = radiator(txsig,tgtang);         
    txsig = channel(txsig,sensorpos,tgtpos,sensorvel,tgtvel);    
    tgtsig = target(txsig);     
    rxcol = collector(tgtsig,tgtang);
    rxsig = receiver(rxcol);   
    cube(:,n) = rxsig;
end
% save fmcwmatlab2018data;
% imagesc([0:(Np-1)]*pri*1e6,[0:(Nr-1)]/fs*1e6,abs(cube))
% xlabel('Slow Time {\mu}s')
% ylabel('Fast Time {\mu}s')
% axis xy
% 
ndop = 128;
rangedopresp = phased.RangeDopplerResponse('SampleRate',fs, ...
    'PropagationSpeed',c,'DopplerFFTLengthSource','Property', ...
    'DopplerFFTLength',ndop,'DopplerOutput','Speed', ...
    'OperatingFrequency',fc);
matchingcoeff = getMatchedFilter(waveform);
[rngdopresp,rnggrid,dopgrid] = rangedopresp(cube,matchingcoeff);
figure;imagesc(dopgrid,rnggrid,10*log10(abs(rngdopresp)))
xlabel('Closing Speed (m/s)')
ylabel('Range (m)')
axis xy
% 
% mfgain = matchingcoeff'*matchingcoeff;
% dopgain = Np;
% noisebw = fs;
% noisepower = noisepow(noisebw,receiver.NoiseFigure,receiver.ReferenceTemperature);
% noisepowerprc = mfgain*dopgain*noisepower;
% noise = noisepowerprc*ones(size(rngdopresp));
% 
% rangeestimator = phased.RangeEstimator('NumEstimatesSource','Auto', ...
%     'VarianceOutputPort',true,'NoisePowerSource','Input port', ...
%     'RMSResolution',rngrms);
% dopestimator = phased.DopplerEstimator('VarianceOutputPort',true, ...
%     'NoisePowerSource','Input port','NumPulses',Np);
% 
% detidx = NaN(2,Numtgts);
% tgtrng = rangeangle(tgtpos,radarpos);
% tgtspd = radialspeed(tgtpos,tgtvel,radarpos,radarvel);
% tgtdop = 2*speed2dop(tgtspd,c/fc);
% for m = 1:numel(tgtrng)
%     [~,iMin] = min(abs(rnggrid-tgtrng(m)));
%     detidx(1,m) = iMin;
%     [~,iMin] = min(abs(dopgrid-tgtspd(m)));
%     detidx(2,m) = iMin;
% end
% 
% ind = sub2ind(size(noise),detidx(1,:),detidx(2,:));
% 
% [rngest,rngvar] = rangeestimator(rngdopresp,rnggrid,detidx,noise(ind))
% [spdest,spdvar] = dopestimator(rngdopresp,dopgrid,detidx,noise(ind))
