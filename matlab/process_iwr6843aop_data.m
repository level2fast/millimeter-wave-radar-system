clear
clf
rx_data = read_dca_1000(file_name="adc_data.bin");
%% IWR68843AOP Medium Range Radar(MRR) Specifications
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 60GHz
% Max Range = 22m
% Range Resolution = 0.08 m or 8cm
% Max Velocity = 35 mph
% Velocity Resolutin = 40 cm
% Max Angular FoV = 180 deg
% Angular Resolution = 28 deg
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define simulation constants
lightspeed = physconst('LightSpeed');
%% Define Radar parameters
tx_antennas = 2;
rx_antennas  = 4;
radar = FmcwRadar();
radar.Pt_watts            = (db2pow(15)/1000) * tx_antennas; % actually milliwats for this radar
radar.Gt_db               = 5; % dBi
radar.Gr_db               = radar.Gt_db;
radar.Freq_Center_hz      = 60e9;
radar.Bandwidth_hz        = 1798e6;
radar.chirp_dur_secs      = 50*1e-6;
radar.frame_time_secs     = 12.8*1e-3;
radar.Lambda_m            = freq2wavelen(radar.Freq_Center_hz,lightspeed); % Wavelength (m)
radar.num_chirps          = 128;
radar.if_max_hz           = 4.5e6; % (IF or Max beat freq)
radar.slope_hz_us         = 30e6;
radar.Fs_hz               = radar.if_max_hz *10; % oversample

% CFAR parameters
pd = 0.9;
pfa = 1e-5;
number_of_samples = 10;

%% RANGE MEASUREMENT
% Reshape the vector into num_rows*num_cols array. num_rows and num_cols here would also define the size of
% Range and Doppler FFT sizes respectively.
num_samples_per_chirp    = radar.num_samples_per_chirp;
num_chirps    = radar.num_chirps;

% Plot range axis
B       = radar.Bandwidth_hz;          % Bandwidth (150 MHz)
c       = physconst('LightSpeed');     % Speed of light
N_FFT   = radar.num_samples_per_chirp; % Size of the FFT

% Calculate Range Resolution
delta_R = c / (2 * B);

% Calcluate SNR detectable
snr_det = calc_min_snr_det(Pd=pd,Pfa=pfa,N=number_of_samples,UseMATLAB="false");

% Calculate Maximum Range (optional simplification for visualization)
range_max = calc_fmcw_max_range(chirp_slope=radar.slope_hz_us, ...
    if_max=radar.if_max_hz)/1e6;

range_max_snr_det = calc_fmcw_max_range_snr_det( ...
    Pt=radar.Pt_watts, ...
    Gr=radar.Gr_db, ...
    Gt=radar.Gt_db, ...
    Sigma=0, ... % dBsm
    N=radar.num_chirps, ...
    Tr=radar.chirp_dur_secs,...
    NF=9, ...
    Fc=radar.Freq_Center_hz, ...
    SNRdet=snr_det);

% Calculate range resolution
range_resolution = bw2rangeres(radar.Bandwidth_hz);

% Use the imagesc function to plot the output of 2DFFT and to show axis in both
% dimensions
% calculate the velocity resolution
idle_time = 100*1e-6;
velocity_res = radar.Lambda_m/(2*radar.num_chirps*radar.chirp_dur_secs); % number of chirps in a frame improves velocity resolution

%% Coherently integrate all 4 channels, 1 for each antenna
frames = 128;
chirps_per_frame = radar.num_chirps;
samples_per_chirp = radar.num_samples_per_chirp;
% rx_frames = reshape(rx_data,[samples_per_chirp chirps_per_frame rx_antennas frames]);

rx_data_ant1 = rx_data(1,:);
rx_data_ant2 = rx_data(2,:);
rx_data_ant3 = rx_data(3,:);
rx_data_ant4 = rx_data(4,:);

rx_ant1_frames = reshape(rx_data_ant1, [samples_per_chirp chirps_per_frame frames]);
rx_ant2_frames = reshape(rx_data_ant2, [samples_per_chirp chirps_per_frame frames]);
rx_ant3_frames = reshape(rx_data_ant3, [samples_per_chirp chirps_per_frame frames]);
rx_ant4_frames = reshape(rx_data_ant4, [samples_per_chirp chirps_per_frame frames]);

% %% RANGE DOPPLER RESPONSE
% coherent_rdm1 = create_coherent_rdm2(cube=rx_frames,n_range=samples_per_chirp,n_dopp=chirps_per_frame);
ant1_coherent_rdm = create_coherent_rdm(cube=rx_ant1_frames,n_range=samples_per_chirp,n_dopp=chirps_per_frame);
ant2_coherent_rdm = create_coherent_rdm(cube=rx_ant2_frames,n_range=samples_per_chirp,n_dopp=chirps_per_frame);
ant3_coherent_rdm = create_coherent_rdm(cube=rx_ant3_frames,n_range=samples_per_chirp,n_dopp=chirps_per_frame);
ant4_coherent_rdm = create_coherent_rdm(cube=rx_ant4_frames,n_range=samples_per_chirp,n_dopp=chirps_per_frame);

%% FFT spatial dimension to build coherent datacube
radar_data_cube = zeros(num_samples_per_chirp, num_chirps, rx_antennas);
% % Populate the radar datacube with range-Doppler maps
radar_data_cube(:,:,1) = ant1_coherent_rdm;
radar_data_cube(:,:,2) = ant2_coherent_rdm;
radar_data_cube(:,:,3) = ant3_coherent_rdm;
radar_data_cube(:,:,4) = ant4_coherent_rdm;
fft_input = 2^nextpow2(rx_antennas)*32;
radar_data_cube = fft(radar_data_cube,2^nextpow2(rx_antennas)*32,3);

%% Plot RDM for all 4 channels
% Range Doppler Map Generation.
% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

% calculate ragne axis
max_range = (radar.num_samples_per_chirp - 1) * delta_R;
range_axis = linspace(-max_range, max_range, radar.num_samples_per_chirp);

% calculate the max velocity
prf = 1 / (radar.chirp_dur_secs + idle_time);
unambig_max_vel = (radar.Lambda_m / 4) * prf;
velocity_axis = linspace(-unambig_max_vel, unambig_max_vel,num_chirps);

% Display the radar datacube slices
numMaps = rx_antennas;

figure;
for i = 1:numMaps
    subplot(2, numMaps/2, i);
    imagesc(range_axis,velocity_axis, fftshift(mag2db(abs(radar_data_cube(:,:,i)))));
    grid minor
    ylabel('velocity [m/s]');
    xlabel('range [m]');
    zlabel('signal strength [dB]')
    title(sprintf('Range-Doppler Map RX Antenna %d', i));
    colorbar;
    colormap jet
    axis xy
end

%% print important radar parameters
fprintf(1,'------------------------------------ \n');
fprintf(1,'Radar Parameters \n');
fprintf(1,'Radar Max Range         \n\t%0.2f meters \n',range_max);
fprintf(1,'Radar Max Range given Target SNR  \n\t%2.2f m\n',(range_max_snr_det));
fprintf(1,'Radar Min SNR for Target detection  \n\t%2.2f dB\n',(snr_det));
fprintf(1,'Radar Center Frequency  \n\t%2.2f GHz \n',   radar.Freq_Center_hz/1e9);
fprintf(1,'Radar Sampling Rate     \n\t%2.2f MHz \n',   radar.Fs_hz/1e6);
fprintf(1,'Radar Bandwidth         \n\t%2.2f MHz\n',    radar.Bandwidth_hz/1e6);
fprintf(1,'Radar I/F               \n\t%2.2f MHz\n',    radar.if_max_hz/1e6);
fprintf(1,'Radar Slope             \n\t%2.2f MHz/us\n', radar.slope_hz_us/1e6);
fprintf(1,'Radar Chirps            \n\t%2.2f  \n',      radar.num_chirps);
fprintf(1,'Radar Chirp Duration    \n\t%2.2f us \n',    radar.chirp_dur_secs*1e6);
fprintf(1,'Radar Range Resolution  \n\t%2.2f m\n',      range_resolution);
fprintf(1,'Radar Velocity Resolution  \n\t%2.7f m\n',velocity_res);
fprintf(1,'Radar Max Velocity  \n\t%2.2f m\n',unambig_max_vel);

%% Display RDM before and after CFAR-CA is applied

% Get convert signal to power
ant1_rdm = mag2db(abs(radar_data_cube(:,:,1)));
ant1_rdm = fftshift(ant1_rdm);

figure(1);
title('Name', 'RDM No CFAR-CA filtering');
ax10 = subplot(1, 2, 1);
imagesc(velocity_axis,range_axis, ant1_rdm);
grid minor
xlabel('velocity [m/s]');
ylabel('range [m]');
zlabel('signal strength [dB]')
title('Range Doppler Map')
colorbar;
colormap jet
axis xy

pfa = 10e-5;
gr = 4;
gd = 4;
tr = 14;
td = 6;

cfar_signal = cfar_2d_rdm(Rdm=ant1_rdm, ...
    Pfa=pfa, ...
    Gr=gr, ...
    Gd=gd, ...
    Tr=tr, ...
    Td=td,...
    NumRangeCells=num_samples_per_chirp, ...
    NumDoppCells=num_chirps, ...
    dopplerAxis=velocity_axis, ...
    rangeAxis=range_axis,...
    PlotData="false");


figure(1);
ax11 = subplot(1, 2, 2);
imagesc(velocity_axis, (range_axis),  cfar_signal);
grid minor;
xlabel('velocity [m/s]');
ylabel('range [m]');
zlabel('signal strength [dBFs]')
title(sprintf('CA-CFAR filtered Range Doppler Response (Pfa=%d )', pfa))
colorbar;
colormap jet
axis xy

% Get detection indices
% 2. Extract detected objects from CFAR-CA detection matrix
[range_idx, velocity_idx] = find(cfar_signal > 0);


%% Calculate AoA
% Use cfar detection outputs to index into the radar datacube to extract
% the proper frequency from the spatial dimension
% calculate the angular resolution
anglular_res = calc_fmcw_angular_res(lambda=radar.Lambda_m, ...
    distance=radar.Lambda_m/2, ...
    num_rx_ant=rx_antennas/2, ...
    num_tx_ant=tx_antennas, ...
    theta=deg2rad(0));

max_unambig_angular_range = asin(radar.Lambda_m/(2 * radar.Lambda_m * (1/2)));

fprintf(1,'Angular Resolution  \n\t%2.2f deg\n', rad2deg(anglular_res));
fprintf(1,'Max unambiguous Angular Range  \n\t(±)%2.2f deg\n', rad2deg(max_unambig_angular_range));

% calculate rx antenna element spacing
element_distance = radar.Lambda_m / 2;

% 1. Get frequency of each detection from spatial dimension
all_ant_detections = get_aoa_vector(datacube=radar_data_cube,...
    range_detection_idx=range_idx,...
    velocity_detection_idx=velocity_idx);

% Find peaks in the spectrum
[m,locs] = max(abs((all_ant_detections).^2),[],1);

% 3. Calculate angle of objects
f_max = 90;
fft_bins = size(radar_data_cube, 3);
angles_axis = linspace(-f_max, f_max - ((f_max * 2) / fft_bins), fft_bins);
figure(4)
plot(angles_axis,mag2db(abs(all_ant_detections(1,:))));
title('Angle of Arrival Frequency Plot 128 zero pad')
angles = mean(angles_axis(locs));

fprintf(1,'Target Angle Estimate  \n\t%2.2f deg\n', 90 + angles);
fprintf(1,'Actual Target Angle  \n\t%2.2f deg\n', rad2deg(atan(1/2)));