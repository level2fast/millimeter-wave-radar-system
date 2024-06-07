function [compressed_sig_out] = match_filter_signal(signal)
%MATCH_FILTER_SIGNAL Computes the matched filter of 2 signals
% NOTE:
% time vec for compressed signal is time_vec = 0:1/Fs:T - (1/Fs)
arguments
    signal.RecvSignal (:,:) {mustBeNonempty}  = 0 
    signal.RefSignal  (:,:) {mustBeNonempty}  = 0 
    signal.Dim        (:,:) {mustBeNonempty}  = 1
end
n_ref    = length(signal.RefSignal(:));
n_data   = size(signal.RecvSignal,1);
n_fft    = n_data + n_ref - 1;
in_freq  = fft(signal.RecvSignal,n_fft,1);
ref_freq = fft(signal.RefSignal(:),n_fft);
out_freq = bsxfun(@times,in_freq,conj(ref_freq));
compressed_sig_out = ifft(out_freq,[],1);
end

