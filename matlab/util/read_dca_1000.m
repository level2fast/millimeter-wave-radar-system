function [retVal] = read_dca_1000(dca1000)
%READDCA100 Summary of this function goes here
% Row 1 contains all of the data from the first receiver, row 2 from the 
% second receiver, row 3 from the third receiver, and row 4 from the fourth
% receiver.
% 
% In cases where certain receivers are disabled, the corresponding
% rows will be removed. 
% 
% Each row will contain a number of columns equal to the number of ADC 
% samples per chirp multiplied by the total number of chirps. The columns 
% are organized by chirps. For example, if there are 256 ADC samples and a 
% total of 16 chirps (8 chirps/frame x 2 frames), each row will contain 
% 4096 columns. The first 256 columns correspond to the first chirp, the 
% next 256 columns to the second chirp, and so on. The first 2048 columns 
% correspond to the chirps of the first frame, and so on.
% The data can then be processed as the user desires.
arguments
    dca1000.file_name       (1,1) {mustBeText}  = "adc_data.bin" 
    dca1000.num_adc_samples (1,1) {mustBeNonnegative}  = 256
    dca1000.num_adc_bits    (1,1) {mustBeNonnegative}  = 16
    dca1000.num_rx          (1,1) {mustBeNonnegative}  = 4
    dca1000.is_real         (1,1) {mustBeNonnegative}  = 0
end
%% This script is used to read the binary file produced by the DCA1000 and Mmwave Studio
%% global variables
% change based on sensor config
fileName      = dca1000.file_name;       % binary file captured by DCA1000
numADCSamples = dca1000.num_adc_samples; % number of ADC samples per chirp
numADCBits    = dca1000.num_adc_bits;    % number of ADC bits per sample
numRX         = dca1000.num_rx;          % number of receivers
isReal        = dca1000.is_real;         % set to 1 if real only data, 0 if complex data0
numLanes      = 2;                       % do not change. number of lanes is always 2

%% read .bin file
fid = fopen(fileName,'r');
adcData = fread(fid, 'int16');

% if 12 or 14 bits ADC per sample compensate for sign extension
if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
end
fclose(fid);

fileSize = size(adcData, 1);
% real data reshape, filesize = numADCSamples*numChirps
if isReal
    numChirps = fileSize/numADCSamples/numRX;
    LVDS = zeros(1, fileSize);
    % create column for each chirp
    LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
    % each row is data from one chirp
    LVDS = LVDS.';
else
    % for complex data
    % filesize = 2 * numADCSamples*numChirps
    numChirps = fileSize/2/numADCSamples/numRX;
    LVDS = zeros(1, fileSize/2);
    % combine real and imaginary part into complex data
    % read in file: 2I is followed by 2Q
    counter = 1;
    for i=1:4:fileSize-1
        LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2); 
        LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3); counter = counter + 2;
    end
    % create column for each chirp
    LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);
    % each row is data from one chirp
    LVDS = LVDS.';
end

% organize data per RX
adcData = zeros(numRX,numChirps*numADCSamples);
for row = 1:numRX
    for i = 1: numChirps
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end

% return receiver data
retVal = adcData;
end

