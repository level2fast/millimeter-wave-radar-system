function [output_signal] = calc_fmcw_angle_fft(angleFft)
arguments
    angleFft.datacube (:,:,:) = 0;
    angleFft.num_range (1,1) {mustBeNonnegative} = 0;
    angleFft.num_angle (1,1) {mustBeNonnegative} = 0;
    angleFft.num_doppler(1,1) {mustBeNonnegative} = 0;
end
datacube = angleFft.datacube;
num_range = angleFft.num_range;
num_doppler = angleFft.num_doppler;
output_signal = complex(zeros(num_range,num_angle,num_doppler));

for n = 1: num_range
    for l = 1: num_doppler
        % Data in different virtual array elements
        datacube = squeeze(datacube(n,:,l)');

        % Add Hann window on data
        XrngdopHannArray = hanning(length(datacube)).*datacube;

        % Angle FFT
        output_signal(n,:,l) = fftshift(fft(XrngdopHannArray,num_angle));
    end
end
end