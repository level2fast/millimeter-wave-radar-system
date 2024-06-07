function [aoa_mat_output] = get_aoa_vector(detections)
%GETAOAVECTOR Extracts the frequency component from the spatial dimension
% of a radar datacube using the range and velocity indices.
arguments
    detections.datacube (:,:,:){mustBeNonempty} = 0
    detections.range_detection_idx {mustBeNonempty} = 0
    detections.velocity_detection_idx {mustBeNonempty} = 0
end
datacube = detections.datacube;
range_idx = detections.range_detection_idx;
velocity_idx = detections.velocity_detection_idx;
fft_size = size(datacube,3);
aoa_mat = zeros(size(range_idx,1),fft_size);

for idx = 1:size(range_idx)
    for idx2 = 1:fft_size
        aoa_mat(idx,idx2) = datacube(range_idx(idx),velocity_idx(idx),idx2);
    end
end
aoa_mat_output = aoa_mat;
end


