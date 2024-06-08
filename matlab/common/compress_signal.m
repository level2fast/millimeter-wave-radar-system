% Mark 10:27 Jesus looked at them and said, "With man it is impossible,
% but not with God. For with God all things are possible."
function [CompressedSignal] = compress_signal(LinearFMChirp,NoisySignal,peformIFFT,NumberOfSamples)
% compress_signal: Function to compress an Linear FM chirp signal
%   This function takes a Linear FM Chirp and a signal with noise
%   as input and computes the match filter to be returned to the caller.
%   This function takes teh complex conjugatea of the dFT of the zero padded
%   pulse replica length(minus one), the FFT length should be a few times longer
%   than the pulse replica length to obtain efficient processing.
%   corresponds to option 2 on page 95 of "Digital Processing of Synthetic 
%   ApertureRadar Data" by Ian G. Cumming and Frank H. Wong. ISBN-13: 978-1-58053-058-3.

[rows, cols] = size(NoisySignal);
fftSize = NumberOfSamples*2;
% Initialize matrix

% Transform range to Frequency domain by performing an
% FFT on each range line(row) of data. See FFT(X,[],DIM) or fft(X,n,2) in
% this case returns the n-point Fourier transform of each row.
NoisySignalFreqDm = fft((NoisySignal),fftSize,2);

% Compute fft on reference signal
ReferenceSignalFreqDm = fft(LinearFMChirp,fftSize);

ReferenceSignalFreqDm = repmat(ReferenceSignalFreqDm,rows, 1);

%Compute Matched filter.
RestoredSignal = conj(ReferenceSignalFreqDm).*NoisySignalFreqDm;

%Perform range IFFT
if(peformIFFT)
    CompressedSignal = ifft(RestoredSignal);
    CompressedSignal(:,cols+1:end) = []; % throw away junk
else
    CompressedSignal = RestoredSignal;

end

