function [rangePhase] = create_complex_slow_time_vec(radar)
%CREATE_COMPLEX_SLOW_TIME_VEC Creates a complex vector spaced by the pulse
% repitition interval(PRI) and 
arguments
    radar.target_range_m (1,1) {mustBeNonempty} = 0
    radar.range_rate_mps (1,1) {mustBeNonempty} = 0
    radar.slow_time_vec  (1,:) {mustBeNonempty} = 0
    radar.freq_center_hz (1,1) {mustBeNonempty} = 0
end
range_m        =  radar.target_range_m;
range_rate_mps =  radar.range_rate_mps;
slow_time_vec  =  radar.slow_time_vec;
freq_center_hz =  radar.freq_center_hz;
c              =  physconst('LightSpeed');

range_slow_time = range_m * range_rate_mps * slow_time_vec.';
range_phase_arg = -4*pi * freq_center_hz / c * range_slow_time;
rangePhase = exp(1j*range_phase_arg);
end


