% Parameters
PRI = 1e-3;               % Pulse Repetition Interval (1 ms)
numPulses = 100;          % Number of pulses
fc = 10e9;                % Carrier frequency (10 GHz)
v = 30;                   % Target velocity (30 m/s)
lambda = 3e8 / fc;        % Wavelength
fd = 2 * v / lambda;      % Doppler frequency shift

% Time vector
t = (0:numPulses-1) * PRI;

% Simulate radar returns
stationary_target = 1;                    % Stationary target return amplitude
moving_target = exp(1j * 2 * pi * fd * t); % Moving target with Doppler shift

% Combined radar returns
radar_returns = stationary_target + moving_target;

% Apply two-pulse MTI canceller
canceller_output = diff([0 radar_returns]);  % Difference of consecutive pulses

% Plot the original and processed signals
figure;
subplot(3,1,1);
plot(t, real(radar_returns));
title('Original Radar Returns');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, real(moving_target));
title('Moving Target Return');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, real(canceller_output));
title('MTI Canceller Output');
xlabel('Time (s)');
ylabel('Amplitude');

% Analyze the output
% Here, we expect to see that the stationary target is suppressed in the MTI output
