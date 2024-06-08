function [sig_out] = cross_correlation(crossCorr)
%CROSS_CORRELATION Caclulates the cross correlation of 2 signals
%   Detailed explanation goes here
arguments
    crossCorr.Sig1 (:,:) {mustBeNonempty} = []
    crossCorr.Sig2 (:,:) {mustBeNonempty} = []
    crossCorr.IdxKeep (1,1) {mustBeNonempty} = 0
    crossCorr.LenFFT (1,1) {mustBeNonempty} = 0
    crossCorr.Dim (1,1) {mustBeNonempty} = 0
end
if(crossCorr.IdxKeep > size(crossCorr.Sig1,1))
    error('Error: samples to keep cant be larger than input signal length')
end

if(crossCorr.Dim > 0 )
    sig1_freq = fft(crossCorr.Sig1, crossCorr.LenFFT,crossCorr.Dim);
    sig2_freq = fft(crossCorr.Sig2(:), crossCorr.LenFFT,crossCorr.Dim);
else
    sig1_freq = fft(crossCorr.Sig1, crossCorr.LenFFT);
    sig2_freq = fft(crossCorr.Sig2(:), crossCorr.LenFFT);    
end

sig_out_freq = bsxfun(@times, sig1_freq,conj(sig2_freq));
sig_out_temp = ifft(sig_out_freq);
sig_out = sig_out_temp(1:crossCorr.IdxKeep,:); 
end
