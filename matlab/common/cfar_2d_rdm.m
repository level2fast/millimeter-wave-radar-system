function [ouput_signal] = cfar_2d_rdm(cfar2dParams)
%CFAR_2D_RDM Summary of this function goes here
%   Detailed explanation goes here
arguments
    cfar2dParams.Rdm (:,:) = 0
    cfar2dParams.Tr (1,1) = 4
    cfar2dParams.Td (1,1) = 4
    cfar2dParams.Gr (1,1) = 2
    cfar2dParams.Gd (1,1) = 2
    cfar2dParams.Pfa (1,1) = 1e-4
    cfar2dParams.NumRangeCells (1,1) = 256
    cfar2dParams.NumDoppCells (1,1) = 128
    cfar2dParams.RangeAxis (1,:) = 0
    cfar2dParams.DopplerAxis (1,:) = 0
    cfar2dParams.PlotData  = "false"
end

%% CFAR implementation
RDM = cfar2dParams.Rdm;
doppler_axis = cfar2dParams.DopplerAxis;
range_axis = cfar2dParams.RangeAxis;
% Slide Window through the complete Range Doppler Map

% Select the number of Training Cells in both the dimensions.
tr = cfar2dParams.Tr;
td = cfar2dParams.Td;

% Select the number of Guard Cells in both dimensions around the Cell
% under test (CUT) for accurate estimation
gr = cfar2dParams.Gr;
gd = cfar2dParams.Gd;

% Offset the threshold by SNR value in dB
num_training_cells = tr + td;
pfa = cfar2dParams.Pfa;
cfar_constant = num_training_cells * (pfa^((-1/num_training_cells)) - 1);

nd = cfar2dParams.NumDoppCells;
nr = int32(cfar2dParams.NumRangeCells);

%Create a vector to store noise_level for each iteration on training cells
radius_doppler   = td + gd;  % no. of doppler cells on either side of CUT
radius_range     = tr + gr;  % no. of range cells on either side of CUT

n_range_cells     = nr - 2 * radius_range; % no. of range dimension cells
n_doppler_cells   = nd - 2 * radius_doppler;   % no. of doppler dim. cells

% grid_size        = (2*Tr + 2*Gr + 1) * (2*Td + 2*Gd + 1); % total grid size Training cells + gaurd cells
% # of guard cells and # of training cells. informational only
% Nguard_cut_cells = (2*Gr+1) * (2*Gd+1);     % no. guards + cell-under-test
% Ntrain_cells     = grid_size - Nguard_cut_cells;  % no. of training cells

% matrix to hold the noise level for each point in the RDM
noise_level      = zeros(n_range_cells,n_doppler_cells);

% Design a loop such that it slides the CUT across range doppler map by
% giving margins at the edges for Training and Guard Cells.
%
% For every iteration sum the signal level within all the training
% cells. To sum convert the value from logarithmic to linear using db2pow
% function. Average the summed values for all of the training
% cells used. After averaging convert it back to logarithmic using pow2db.
%
% Further add the offset to it to determine the threshold. Next, compare the
% signal under CUT with this threshold. If the CUT level > threshold assign
% it a value of 1, else equate it to 0.

% Use RDM[x,y] as the matrix from the output of 2D FFT for 
% implementing CFAR.
cfar_signal = zeros(size(RDM));

% Need to define the min and max range values to avoid running outside
% the bounds of the range dimension
r_min = radius_range + 1;            % starting index of range dimension
r_max = n_range_cells - radius_range; % last index of range dimension

% Need to define the min and max range values to avoid running outside
% the bounds of the doppler dimension
d_min = radius_doppler + 1;              % starting index of doppler dimension
d_max = n_doppler_cells - radius_doppler; % last index of doppler dimension

% Loop accross range and doppler dimensions starting from the lowest
% range and doppler cell 
for r = r_min : r_max
    for d = d_min : d_max
		% exract the cell that'll be used for detection threshold
        cell_under_test = RDM(r, d);
		% initialze variable to track # of cells which is need for computing
		% the average noise power of the training cells
        cell_count = 0;
		
		% Loop over each range and doppler training cell within the training 
		% window 
        for delta_r = -radius_range : radius_range
            for delta_d = -radius_doppler : radius_doppler
                
				% calculate the current position of each range and doppler cell
				% in the training window to determine if the current cells can be
				% used in the cell averaging step
                cr = r + delta_r;
                cd = d + delta_d;
                
				% determine if current range and current doppler cells are within the training window
                in_valid_range = (cr >= 1) && (cd >= 1) && (cr < n_range_cells) && (cd < n_doppler_cells);
                in_train_cell = abs(delta_r) > gr || abs(delta_d) > gd;
                
				% ensure we are not outside of the bounds of the range or doppler dimensions
				% and make sure we are looking at training cells and not gaurd cells
                if in_valid_range && in_train_cell
                    try
					    % convert RDM sample to linear scale in preparation for averaging step
                        noise = db2pow(RDM(cr,cd));
                    catch 
                         error('Invalid indice.');
                    end
                    noise_level(r, d) = noise_level(r, d) + noise;
                    cell_count = cell_count + 1;
                end
            end
        end

        % Calculate threshold by finding the average noise level
		% in the training cells and adding multiplying by the cfar constant.
        threshold = pow2db((noise_level(r, d) / cell_count)* cfar_constant) ;
		
        % If the signal in the cell under test (CUT) exceeds the
        % threshold, we mark the cell as hot by setting it to 1.
        % We don't need to set it to zero, since the array
        % is already zeroed out.
        if (cell_under_test >= threshold)
            cfar_signal(r, d) = RDM(r, d); % ... or set to 1
        end
    end
end

if(cfar2dParams.PlotData == "true")
    % Display the CFAR output using the Surf function like we did for Range
    % Doppler Response output.
    figure(98);
    title('Name', 'CA-CFAR Filtered RDM');
    ax1 = subplot(1, 2, 1);
    surfc( range_axis, doppler_axis, RDM.', 'LineStyle', 'none');
    alpha 0.75;
    xlabel('velocity [m/s]');
    ylabel('range [m]');
    zlabel('signal strength [dB]')
    title('Contour Range Doppler Response')
    colorbar;
    colormap jet
    axis xy

    ax2 = subplot(1, 2, 2);
    surf(range_axis, flip(doppler_axis), cfar_signal.', 'LineStyle', 'none');
    %imagesc(doppler_axis, (range_axis),  cfar_signal);
    grid minor;
    ylabel('velocity [m/s]');
    xlabel('range [m]');
    zlabel('signal strength [dBFs]')
    title(sprintf('CA-CFAR filtered Range Doppler Response (Pfa=%d )', pfa))
    colorbar;
    colormap jet
    axis xy
end
ouput_signal = cfar_signal;
end

