function [f_time_comp_vs_s_time_comp_mat] = create_signal_data(sigData)
%CREATE_SIGNAL_DATA Generates signal data for a single target accross 1 coherent processing interval(CPI)
arguments
    sigData.target      {mustBeNonempty}= 0
    sigData.radar       {mustBeNonempty}= 0
    sigData.waveform    {mustBeNonempty}= 0
    sigData.rngVec      {mustBeNonempty}= 0
    sigData.slowTimeVec {mustBeNonempty}= 0
end
rel_range      = sigData.target.range;
rel_range_rate = sigData.target.range_rate;
rcs_dbsm       = sigData.target.rcs_dbsm;

% initialize get sample number
n_samples_pri = round(sigData.radar.sample_rate_hz/sigData.radar.prf_hz);
waveform_norm = sigData.waveform./norm(sigData.waveform);

% create range fast time vector
rng_fast_time_vec_complex = zeros(n_samples_pri,1);

% create slow time vector
slow_time_vec_complex = create_complex_slow_time_vec(freq_center_hz = radar.freq_center_hz,...
                                                     range_rate_mps = rel_range_rate,...
                                                     slow_time_vec  = sigData.slowTimeVec,...
                                                     target_range_m = rel_range);
rng_fast_time_vec_complex = waveform_norm;

% create target fast time vs. slow time matrix
f_time_comp_vs_s_time_comp_mat = rng_fast_time_vec_complex * slow_time_vec_complex;
end

