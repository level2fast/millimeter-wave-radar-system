classdef FmcwRadar < Radar
    %FMCWRADAR Summary of this class goes here
    %   Detailed explanation goes here
    properties
        chirp_dur_secs  (1,1) {mustBeNumeric} = 0 % duration of a single chirp
        frame_time_secs (1,1) {mustBeNumeric} = 0 % total frame time
    end
end

