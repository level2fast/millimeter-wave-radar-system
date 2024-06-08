function [max_unambiguous_vel_fmcw] = calc_fmcw_max_velocity(maxVelArgs)
%CALC_MAX_VELOCITY_FMCW Summary of this function goes here
% Along with the distance, the relative velocity of the object is another critical parameter of interest. The
% maximum measurable velocity in Fast FMCW modulated radars depends on the chirp cycle time, that is,
% the time difference between the start of two consecutive chirps. This in turn depends on how fast the
% frequency sweep can be performed and the minimum inter-chirp time allowed.
arguments
    maxVelArgs.lambda (1,1) {mustBeNonnegative} = 0;
    maxVelArgs.total_chirp_time (1,1) {mustBeNonnegative} = 0;

end
max_unambiguous_vel_fmcw = maxVelArgs.lambda/(4*maxVelArgs.total_chirp_time);
end

