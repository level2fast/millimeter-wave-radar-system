classdef Radar
    %RADAR Base class for Radar object. This class defines properties
    % needed for a basic radar system.
    properties(Access = public)
        % Radar operating conditions
        Pt_watts  (1,1) {mustBeNumeric} = 0   % Peak Transmit Power Watts
        Gt_db     (1,1) {mustBeNumeric} = 0   % Gain of transmitter
        Gr_db     (1,1) {mustBeNumeric} = 0   % Gain of receiver
        Lambda_m  (1,1) {mustBeNumeric} = 0   % wavelength
        R_m       (1,1) {mustBeNumeric} = 0   % range betweed radar and target
        T_celc    (1,1) {mustBeNumeric} = 290 % operating temperature
        F_db      (1,1) {mustBeNumeric} = 0   % receiver noise figure
        L_db      (1,1) {mustBeNumeric} = 0   % system path loss

        % motion properties
        Plat_Pos_m   {mustBeReal, mustBeVector} = [0;0;0;]
        Plat_Vel_m_s {mustBeReal, mustBeVector} = [0;0;0;]

        % Waveform properties
        Bandwidth_hz   (1,1) {mustBeNumeric} = 0 % bandwidth
        Fs_hz          (1,1) {mustBeNumeric} = 0 % sampling rate
        Prf_hz         (1,1) {mustBeNumeric} = 0 % pulse repitition frequency
        Pulse_Width_s  (1,1) {mustBeNumeric} = 0 % transmitted pulse width/duration
        Freq_Center_hz (1,1) {mustBeNumeric} = 0 % radar carrier frequency

        % Dwell properties
        Tcpi_s         {mustBeReal} = 0 % radar CPI time depends on the time 
                                        % that an antenna beam spends on target
        N_pulses       {mustBeReal} = 0 % number of pulses per dwell 
                                    
        % Parameter selection
        Duty_Factor        {mustBeReal} = 0 % ratio of pulse width to the period
        Antenna_Diameter_m {mustBeReal} = 0 % length of antenna
    end
    properties(Access=protected)
        Boltzman {mustBeNumeric} = physconst('Boltzmann')  % boltzman constant
        C_mps    {mustBeNumeric} = physconst('LightSpeed') % speed of light
    end

end


