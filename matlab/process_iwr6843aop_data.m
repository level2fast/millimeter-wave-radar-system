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
radar.Freq_Center_hz = 60e9;
radar.Bandwidth_hz   = 1500e6;
radar.Chirp_Duration_secs = 50*1e6;
radar.Frame_time_secs     = 12.8*1e3;
radar.Lambda_m       = freq2wavelen(radar.Freq_Center_hz,lightspeed); % Wavelength (m)
radar.Prf_hz         = 1/radar.Pulse_Width_s;
radar.N_pulses       = 128;
radar.Fs_hz          = 0; % todo: need to calculate this param

%% Process 1 RX channel of data
