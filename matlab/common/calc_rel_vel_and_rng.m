function [range,range_rate,los] = calc_rel_vel_and_rng(posParams)
%CALC_REL_VEL_AND_RNG Calculate relative velocity and and range between a radar platform and target
%   Detailed explanation goes here
arguments
    posParams.PlatPos (1,:) {mustBeNonnegative}  = 0 
    posParams.PlatVel (1,:) {mustBeNonnegative}  = 0
    posParams.TgtPos  (1,:) {mustBeNonnegative}  = 0 
    posParams.TgtVel  (1,:) {mustBeNonnegative}  = 0
end
pos_diff = posParams.TgtPos - posParams.PlatPos;
vel_diff = posParams.TgtVel - posParams.PlatVel;
range = norm(pos_diff);
los = (pos_diff)./range;
range_rate = dot(vel_diff,los);
end

