function write_to_cloud_database(sensorData)
%WRITE_TO_CLOUD_DATABASE Summary of this function goes here
%   Detailed explanation goes here
arguments
    sensorData.X (1,1) = 0 
    sensorData.Y (1,1) = 0
    sensorData.Z (1,1) = 0
    sensorData.command = "C:\Github\\millimeter-wave-radar-system\\visualizer\\firebase_write.py "
    sensorData.program = "python "
end

% prepare input for concatenation step
x = string(sensorData.X);
y = " " + string(sensorData.Y);
z = " " + string(sensorData.Z);

% create command to send to system
command = strcat(sensorData.program,sensorData.command, x, y,z);

% write data to database
system(command);
end

