function [dopp_freq,dopp_freq_ambig,range_rate_apparent] = calc_dopp_params(doppParams)
%CALC_DOPP_PARAMS Summary of this function goes here
%   Detailed explanation goes here
arguments
    doppParams.wavelength_m       (1,1){mustBeNonempty} = 0
    doppParams.rel_range_rate_mps (1,1){mustBeNonempty} = 0
    doppParams.prf_hz             (1,1){mustBeNonempty} = 0
end
wavelength_m = doppParams.wavelength_m;
rel_range_rate_mps = doppParams.rel_range_rate_mps;
prf_hz = doppParams.prf_hz;

range_rate_to_dop = -2/wavelength_m;
dopp_freq = (-2 * rel_range_rate_mps)/wavelength_m; % real doppler value of target that we're looking for
k = round(dopp_freq ./ prf_hz);
if(k > 0)
    warning('ambiguity index k %d is greater than zero',k)
else
    msg = sprintf('Doppler ambiguity is:%d, target return will be received within a PRI',k);
    disp(msg)
end

dopp_freq_ambig = dopp_freq - (k*prf_hz); % doppler value of target factoring 
                                          % in ambiguity index which determines which PRI our return is in

range_rate_apparent = dopp_feq_ambig / range_rate_to_dop; % range rate value of target as it appears to the radar at each PRF
end

