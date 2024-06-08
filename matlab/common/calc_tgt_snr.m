function [SNR] = calc_tgt_snr(rngEq)
%CALC_TGT_SNR Calculates the the signal to noise ratio for a specific target radar cross section i.e. sigma(dbsm)
% Pt — Peak transmit power in watts
% Gt — Transmit antenna gain
% Gr — Receive antenna gain. If the radar is monostatic, the transmit and receive antenna gains are identical.
% λ — Radar wavelength in meters (m)
% σ — Target's nonfluctuating radar cross section in square meters (dBsm)
% L — General loss factor in decibels that accounts for both system and
% propagation loss (dB)
% R — Range from the transmitter to the target (m)
arguments
    rngEq.Pt (1,1) {mustBeNumeric} = 0
    rngEq.Gt (1,1) {mustBeNumeric} = 0
    rngEq.Gr (1,1) {mustBeNumeric} = 0
    rngEq.Sigma (1,1) {mustBeNumeric} = 0
    rngEq.Lambda (1,1) {mustBeNumeric} = 0
    rngEq.R (1,1) {mustBeNumeric} = 0
    rngEq.T (1,1) {mustBeNumeric} = 290
    rngEq.B (1,1) {mustBeNumeric} = 0
    rngEq.F (1,1) {mustBeNumeric} = 0
    rngEq.L (1,1) {mustBeNumeric} = 0
end

Pt     = rngEq.Pt;
Sigma  = db2pow(rngEq.Sigma);
F      = db2pow(rngEq.F);
L      = db2pow(rngEq.L);
Gt     = db2pow(rngEq.Gt);
Gr     = db2pow(rngEq.Gr);

Lambda = rngEq.Lambda;
R = rngEq.R;
T = rngEq.T;
K = physconst('Boltzman');
B = rngEq.B;
num = (Pt .* Gt * Gr .* Sigma * (Lambda^2));
den = ((4 * pi)^3 * (R.^4) *K * T * B * F * L);
SNR = num./den;
% SNR is in linear scale so we can use 10*log10(SNR) to get power value in decibels(dB) 
end


