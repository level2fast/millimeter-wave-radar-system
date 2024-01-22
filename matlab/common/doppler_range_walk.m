function range_walk = doppler_range_walk(relative_velocity, pulse_duration)
    % Doppler-induced range walk modeling
    % Input:
    %   - relative_velocity: Relative velocity between radar and target (meters per second)
    %   - pulse_duration: Duration of radar pulse (seconds)
    % Output:
    %   - range_walk: Estimated range walk due to Doppler effect
arguments
    relative_velocity {mustBeNonempty}    = 0
    pulse_duration    {mustBeNonnegative} = 0
end

    % Speed of light (meters per second)
    c = physconst('LightSpeed');
    
    % Calculate range walk using the Doppler formula
    range_walk = (2 * relative_velocity * pulse_duration) / c;
end
