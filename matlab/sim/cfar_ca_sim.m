close all;
%% CFAR-CA Algorithm Simulation
% data points
num_samp  = 1000;

% generate noise
sig =  abs(randn(num_samp,1));

% create random amplitudes that represent target detections
sig([100, 200, 350, 700]) = [0 , 15, 7, 13];

% plot noise 
figure(1)
plot(sig);

% apply CFAR to detect the targets by filtering out noise

% define CFAR window and plot hte optimal number of training and gaurd
% cells

% cell under test: central cell for which the local statistics, such as the 
% average or median intensity, are computed. It's the cell for which the 
% detection threshold is ultimately determined.
cut = 0;

% training cells:  Training cells are similar to guard cells but are located 
% farther away from the reference cell. They are used to estimate the
% background clutter level in regions where the target signal is not 
% expected to be present.
train_cells = 12;

% Guard cells: located around the reference cell and are used to estimate 
% the noise level or clutter background. These cells provide additional
% samples to the CFAR algorithm to improve the accuracy of the background 
% estimation
guard_cells = 4;


% Add rows above noise thresheold for desired SNR. Here we are working on
% linear values, hence we multiply the offset to the threshold value
offset = 5;

% Thresholded signal: threshold values
threshold_cfar = [];

% signal after cfar: final signal with lowered noise floor
signal_after_cfar = [];

% computer 1D cfar

% find radius of range cells
radius_range     = train_cells + guard_cells;  % no. of range cells on either side of CUT

% create noise level vector
noise_level      = zeros(size(sig));

% For every iteration sum the signal level within all the training
% cells. To sum convert the value from logarithmic to linear using db2pow
% function. Average the summed values for all of the training
%
% cells used. After averaging convert it back to logarithmic using pow2db.
% Further add the offset to it to determine the threshold. Next, compare the
% signal under CUT with this threshold. If the CUT level > threshold assign
% it a value of 1, else equate it to 0.
%
% Use sig(n) as the vector from the output of implementing CFAR.
for i = 1:(num_samp - (guard_cells+train_cells+1))
    % calculate average noise by adding all the training cells 
    noise_level = sum(sig((i:i +train_cells -1)));

    % calculate threshold 
    threshold = (noise_level/train_cells) * offset;
    threshold_cfar = [threshold_cfar,(threshold)];

    % extract cell under test
    cut = sig(i + train_cells + guard_cells + 1);

    % peform detection by comparing cell under test with threshold
    if(cut < threshold)
        cut = 0;
    end
    signal_after_cfar = [signal_after_cfar, (cut)];
end

figure(2)
title('Name', 'CA-CFAR Filtered RDM');
grid on
plot(sig)
hold on
plot((circshift(threshold_cfar,guard_cells)),'r--','LineWidth',2);
hold on
plot((circshift(signal_after_cfar,(train_cells + guard_cells))),'g--','LineWidth',3);
hold off
legend('Signal','Threshold CFAR','CFAR-CA Signal')
xlabel('Sample');
ylabel('Amplitude');
