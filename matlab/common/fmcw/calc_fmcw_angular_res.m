function [angular_resolution_deg] = calc_fmcw_angular_res(angResArgs)
% %CALC_ANGULAR_RES_FMCW Calculate the angular resolutio of a radar
% Apart from the angular field of view, it might also be important to resolve two objects at close by angles,
% that is, have good angular resolution. For example, in an automotive radar use case, it would be important
% to detect two cars far off in two different lanes rather than detect them as one single car. In general, the
% angular resolution measurement depends on the number of receiver antennas available. The larger the
% number of antennas, the better the resolution.
%   Detailed explanation goes here
arguments
    angResArgs.lambda (1,1) {mustBeNonnegative} = 0;
    angResArgs.distance (1,1) {mustBeNonnegative} = 0;
    angResArgs.num_rx_ant(1,1) {mustBeNonnegative} = 0;
    angResArgs.num_tx_ant (1,1) {mustBeNonnegative} = 0;
    angResArgs.theta (1,1) {mustBeNonempty} = 0;
    angResArgs.mimo(1,1){mustBeText} = "false"
end
lambda = angResArgs.lambda;
distance = angResArgs.distance;
num_rx_ant = angResArgs.num_rx_ant;
num_tx_ant = angResArgs.num_tx_ant;
theta = angResArgs.theta;
mimo = angResArgs.mimo;
if(mimo == "true")
    angular_resolution_deg = (lambda/(distance * num_tx_ant * num_rx_ant * ...
        cos(theta))) * (180/pi);
else
    angular_resolution_deg = (lambda/(distance * num_rx_ant *cos(theta)));
end

end

