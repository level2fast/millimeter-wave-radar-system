clc;
clear;
close all;

% Parameters
fc = 60e9; % Carrier frequency (24.125 GHz for K-band radar)
c = 3e8; % Speed of light (m/s)
lambda = c / fc; % Wavelength (m)
d = lambda / 2; % Element spacing (half wavelength)
M = 12; % Number of receive antennas

% Generate synthetic data
% Define angles of arrival for two targets
theta1 = 30; % degrees
theta2 = -20; % degrees
angles = [theta1, theta2];

% Generate received signal at each antenna
% Assuming equal signal strength and no noise for simplicity
signal1 = exp(1j * 2 * pi * (0:M-1)' * sin(deg2rad(theta1)) * d / lambda);
signal2 = exp(1j * 2 * pi * (0:M-1)' * sin(deg2rad(theta2)) * d / lambda);

% Combine signals for each receive antenna
Rx_signal = signal1 + signal2;

% Perform Angle FFT
angle_scan = -90:0.1:90; % Angle scan range
N_fft = 1024; % Number of FFT points
angle_fft = fftshift(fft(Rx_signal, N_fft));

% Calculate angle spectrum
angle_spectrum = abs(angle_fft) / max(abs(angle_fft)); % Normalize

% Corresponding angle axis
angles_axis = asin(linspace(-1, 1, N_fft)) * (180/pi);

% Plot Angle FFT Spectrum
figure(99);
plot(angles_axis, mag2db(angle_spectrum), 'LineWidth', 2);
xlabel('Angle (degrees)');
ylabel('Magnitude (dB)');
title('Angle FFT Spectrum');
grid on;

% Find peaks in the spectrum
[pks, locs] = findpeaks(20*log10(angle_spectrum), 'SortStr', 'descend', 'NPeaks', 2);

% Display estimated angles of arrival
estimated_angles = angles_axis(locs);
disp('Estimated Angles of Arrival (degrees):');
disp(estimated_angles);
