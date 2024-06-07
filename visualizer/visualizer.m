clear serial;
serial = serialport("COM5", 921600, "ByteOrder", "little-endian");

sync_pattern = uint64(0x0201040306050807);

% set to zero to use matlab visualizer and skip writing to cloud
only_use_matlab_visualizer = 0;

range_bins = 256;
doppler_bins = 16;
max_range = 9.02;
max_velocity = 1;

range_bin_values = linspace(-max_range/2, max_range/2, range_bins);
dopp_bin_values = linspace(-max_velocity, max_velocity, doppler_bins);

figure("Name", "Range Profile");
range_axes = gca;
rp = plot(range_axes, range_bin_values, zeros(size(range_bin_values)));
ylim(range_axes, [10 20]);
xlim(range_axes, [min(range_bin_values), max(range_bin_values)]);
title 'Zero-Doppler Range Profile'
xlabel 'Range (m)'
ylabel 'Magnitude (dB)'

figure("Name", "Range-Doppler Heat Map");
rdm_axes = gca;
zs = zeros([doppler_bins range_bins]);
zs(1) = mag2db(2^15 - 1);
[~,rdm] = contourf(rdm_axes, range_bin_values, dopp_bin_values, zs, 100, 'LineColor', 'none');
colorbar(rdm_axes);
title 'Range-Doppler Map'
xlabel 'Range (m)'
ylabel 'Velocity (m/s)'
zlabel 'Magnitude (dB)'

figure("Name", "Point Cloud");
point_cloud_axes = gca;
pc = plot3(point_cloud_axes, 0, 0, 0, '+');

xlim(point_cloud_axes, [-9 9]);
ylim(point_cloud_axes, [-9 9]);
zlim(point_cloud_axes, [-3 3]);

while true
    sync_register = uint64(0);

    % Search for start of serial packet by looking for magic byte pattern
    while true
        byte_read = read(serial, 1, "uint8");

        sync_register = bitshift(sync_register, 8);
        sync_register = bitor(sync_register, byte_read);

        if sync_register == sync_pattern
            break;
        end
    end

    version = read(serial, 1, "uint32");
    totalPacketLen = read(serial, 1, "uint32");
    platform = read(serial, 1, "uint32");
    frameNumber = read(serial, 1, "uint32");
    timeCpuCycles = read(serial, 1, "uint32");
    numDetectedObj = read(serial, 1, "uint32");
    numTLVs = read(serial, 1, "uint32");
    subFrameNumber = read(serial, 1, "uint32");

    % fprintf("Frame Number: %u\n", frameNumber);

    for idx = 1:numTLVs
        type = read(serial, 1, "uint32");
        length = read(serial, 1, "uint32");

        if length == 0
            continue;
        end
        
        if(only_use_matlab_visualizer == 0)
            if(type ~= 1)
                continue
            end
        end
        switch type
            % Type 1 - Point Cloud
            case 1
                values = read(serial, length / 4, "single");

                pc_x = values(1:4:end);
                pc_y = values(2:4:end);
                pc_z = values(3:4:end);
                pc_vel = values(4:4:end);

                if(only_use_matlab_visualizer ~= 1)
                    % calculate the vector norm of 3D points with respecto
                    % radar
                    range = vecnorm([pc_x,pc_y,pc_z]);
                    % send data to cloud database
                    write_to_cloud_database(X=range,Y=pc_vel(1));
                end
                pc.XData = pc_x;
                pc.YData = pc_y;
                pc.ZData = pc_z;

            % Type 2 = Zero-Doppler Range Profile
            case 2
                values = read(serial, length / 2, "uint16");

                ys = fftshift(mag2db(values / 512));

                rp.YData = ys;

            % Type 5 = Range-Doppler Heat Map
            case 5
                values = read(serial, length / 2, "uint16");

                rdm_values = mag2db(fftshift(reshape(values, [], range_bins)));

                rdm.ZData = flipud(rdm_values);
                

            % Other types; just read past the data segment
            otherwise
                read(serial, length, "uint8");
        end
    end
end
