function [peak_tgt] = find_idx_of_peak_return(peakTgtReturn)
%FIND_IDX_OF_PEAK_RETURN Calculate the frequency sample index the signal
% will be in after DFT processing
arguments
    peakTgtReturn.Dopp_hz {mustBeNonnegative}  = 0 
    peakTgtReturn.Prf_hz  {mustBeNonnegative}  = 0 
    peakTgtReturn.N       {mustBeNonnegative}  = 0 
end
dopp_hz = peakTgtReturn.Dopp_hz;
prf_hz = peakTgtReturn.Prf_hz;
N = peakTgtReturn.N;
k_tgt_ambig = dopp_hz/prf_hz;
k_tgt = mod(k_tgt_ambig,N);
peak_tgt = round(k_tgt);
end

