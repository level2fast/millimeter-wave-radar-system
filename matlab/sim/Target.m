classdef Target
    %Target Base class for Target object. This class defines properties
    % needed for a basic radar system.
    properties(Access = public)
        % motion properties
        Plat_Pos_m   {mustBeReal} = 0
        Plat_Vel_m_s {mustBeReal} = 0

        % Parameter selection
        Rcs_dbsm     {mustBeReal} = 0 % target cross section(decibel square meters)
    end
end


