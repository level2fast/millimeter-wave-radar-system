function [max_range_fmcw] = calc_fmcw_max_range_snr_det(rngEq)
%CALC_MAX_RANGE_SNR_DET Calculates the the signal to noise ratio for a specific target radar
%   cross section i.e. sigma(dbsm).
%   Returns the signal to noise ration of signal received by the receiver.
%
% Pt - Peak transmit power in watts
% Gr - Transmit antenna gain
% Gt - Receive antenna gain. If the radar is monostatic, the transmit and receive antenna gains are identical.
% σ  - Target's nonfluctuating radar cross section in square meters (dBsm)
% N  - Number of chirps
% Tr - Chirp time
% NF - Noise figure of the receiver(dB)
% k - Boltzman constant
% T -  Ambient temperature
% SNRdet — minimum SNR required by the algorithm to detect an object (dB)
arguments
    rngEq.Pt (1,1) {mustBeNumeric} = 0
    rngEq.Gt (1,1) {mustBeNumeric} = 0
    rngEq.Gr (1,1) {mustBeNumeric} = 0
    rngEq.Sigma (1,1) {mustBeNumeric} = 0
    rngEq.N (1,1) {mustBeNumeric} = 0
    rngEq.Tr (1,1) {mustBeNumeric} = 0
    rngEq.Fc (1,1) {mustBeNumeric} = 0
    rngEq.T (1,1) {mustBeNumeric} = 290
    rngEq.NF (1,1) {mustBeNumeric} = 0
    rngEq.SNRdet (1,1) {mustBeNumeric} = 0
end

Pt     = rngEq.Pt;
Gt     = db2pow(rngEq.Gt);
Gr     = db2pow(rngEq.Gr);
Sigma  = db2pow(rngEq.Sigma);
N      = rngEq.N;
Tr     = rngEq.Tr;
Fc     = rngEq.Fc;
NF     = db2pow(rngEq.NF);
SNRdet = db2pow(rngEq.SNRdet);
c = physconst('LightSpeed');
Lambda = c/Fc; % c= lamda*fc, lamda = c/fc
T = rngEq.T;
K = physconst('Boltzman');

num = (Pt * Gt * Gr * c^2 * Sigma * N * Tr);
den = ((Fc^2) * (4 * pi)^3 * K * T * NF * SNRdet);
ratio = num / den;
max_range_fmcw = nthroot(ratio,4);
% SNR is in linear scale so we can use 10*log10(SNR) to get power value in decibels(dB) 
end

