function [max_unambiguous_vel_res_fmcw] = calc_fmcw_max_velocity_res(maxVelResArgs)
%CALC_MAX_VELOCITY_FMCW Summary of this function goes here
% Along with the distance, the relative velocity of the object is another critical parameter of interest. The
% maximum measurable velocity in Fast FMCW modulated radars depends on the chirp cycle time, that is,
% the time difference between the start of two consecutive chirps. This in turn depends on how fast the
% frequency sweep can be performed and the minimum inter-chirp time allowed.
arguments
    maxVelResArgs.lambda (1,1) {mustBeNonnegative} = 0;
    maxVelResArgs.total_chirp_time (1,1) {mustBeNonnegative} = 0;
    maxVelResArgs.num_chirps_in_frame (1,1) {mustBeNonnegative} = 0;

end
lambda =  maxVelResArgs.lambda;
total_chirp_time = maxVelResArgs.total_chirp_time;
num_chirps_in_frame =maxVelResArgs.num_chirps_in_frame;

max_unambiguous_vel_res_fmcw = lambda/(2*num_chirps_in_frame*total_chirp_time);
end

