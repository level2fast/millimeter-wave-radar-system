% MATLAB Script to Convert Angle of Arrival to Position in Meters

% Constants
d = 0.5; % Distance between sensors in meters
lambda = freq2wavelen(60e9); % Wavelength of the signal in meters

% Input
AoA_deg = input('Enter the Angle of Arrival (AoA) in degrees: ');
AoA_rad = deg2rad(AoA_deg); % Convert degrees to radians

% Calculate position in meters
% Using the formula: y = d * sin(AoA)
y = d * sin(AoA_rad);

% Display the result
fprintf('The position corresponding to the AoA of %.2f degrees is %.2f meters.\n', AoA_deg, y);

% For multiple sensors and a linear array, we could extend this script to compute the positions for each sensor
num_sensors = 5; % For example, a 5-sensor array
positions = zeros(1, num_sensors);

for i = 1:num_sensors
    positions(i) = (i-1) * d + y;
end

% Display the sensor positions
disp('Sensor positions in meters:');
disp(positions);
