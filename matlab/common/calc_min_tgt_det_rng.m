function [R] = calc_min_tgt_det_rng(detRng)
%CALC_MIN_TGT_DET_RNG Calculates target range using CPI and DF version of the radar range equation
%   Detailed explanation goes here
arguments
    detRng.Pt (1,1) {mustBeNumeric} = 0
    detRng.Gt (1,1) {mustBeNumeric} = 0
    detRng.Gr (1,1) {mustBeNumeric} = 0
    detRng.Sigma (1,1) {mustBeNumeric} = 0
    detRng.Fc (1,1) {mustBeNumeric} = 0
    detRng.R (1,1) {mustBeNumeric} = 0
    detRng.T (1,1) {mustBeNumeric} = 290
    detRng.SnrThresh (1,1) {mustBeNumeric} = 0
    detRng.F (1,1) {mustBeNumeric} = 0
    detRng.L (1,1) {mustBeNumeric} = 0
    detRng.Cpi (1,1) {mustBeNumeric} = 0
    detRng.Df (1,1) {mustBeNumeric} = 0
end

Pt  = detRng.Pt;
Cpi = detRng.Cpi;
Df  = detRng.DF;
T   = detRng.T;

lambda = physconst('LightSpeed'/detRng.Fc);
k      = physconst('Boltzman');

Gt         = db2pow(detRng.Gt);
Sigma      = db2pow(detRng.Sigma);
F          = db2pow(detRng.F);
L          = db2pow(detRng.L);
threshold  = db2pow(detRng.SnrThresh);
Gr  = Gt;

num = (Pt .* Gt * Gr .* Sigma * (lambda^2)) * Cpi * Df;
den = ((4 * pi)^3 * (threshold) *k * T * F * L);
R   = num./den;
end

