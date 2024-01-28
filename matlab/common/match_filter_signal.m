function [compressed_sig_out] = match_filter_signal(signal)
%MATCH_FILTER_SIGNAL Summary of this function goes here
% NOTE:
% time vec for compressed signal is
% time_vec = 0:1/Fs:T - (1/Fs)
arguments
    signal.RecvSignal (:,:) {mustBeNonempty}  = 0 
    signal.RefSignal  (:,:) {mustBeNonempty}  = 0 
    signal.Dim        (:,:) {mustBeNonempty}  = 1
end
% recv_data_size = size(signal.RecvSignal,1);
% ref_sig_len    = length(signal.RecvSignal(:));
% fft_len        = recv_data_size + ref_sig_len - 1;
% compressed_sig_out = cross_correlation(Sig1=signal.RecvSignal, ...
%                                        Sig2=signal.RefSignal, ...
%                                        IdxKeep=recv_data_size, ...
%                                        LenFFT=fft_len,...
%                                        Dim=signal.Dim);

nRef = length(signal.RefSignal(:));
nData = size(signal.RecvSignal,1);
nFFT = nData + nRef-1;
inFreq =fft(signal.RecvSignal,nFFT,1);
refFreq = fft(signal.RefSignal(:),nFFT);
outFreq = bsxfun(@times,inFreq,conj(refFreq));
compressed_sig_out = ifft(outFreq,[],1);
end

