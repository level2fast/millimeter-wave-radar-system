function [lags,auto_corr_fcn] = auto_correlation(autoCorrelation)
%AUTOCORRELATION Summary of this function goes here
%   Detailed explanation goes here
arguments
    autoCorrelation.Wvf (1,:) {mustBeNonempty} = 0
end
n_wvf = length(autoCorrelation.Wvf);
L = 2 * n_wvf - 1;
wvf_freq = fft(autoCorrelation.Wvf,L);
auto_corr_fcn = ifft(wvf_freq .* conj(wvf_freq));
auto_corr_fcn = fftshift(auto_corr_fcn);
lags = -(n_wvf-1):(n_wvf-1);
end

