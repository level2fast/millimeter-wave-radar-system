function [min_det_snr] = calc_min_snr_det(snrDet)
%CALC_SNR_DET This function calculates the minimum detectable SNR 
%   The calculation uses Shidnmans equation to compute the single sample SNR
%   required to achieve a specified Pd and Pfa for a nonfluctuating target.
%   A non-fluctuating target refers to a target whose radar cross section (RCS)
%   remains constant over time. The RCS is a measure of how much power is 
%   reflected back to the radar receiver by the target, and for a non-fluctuating
%   target, this measure does not vary with different aspects or
%   orientations of the target.
arguments
    snrDet.Pd (1,1) {mustBePositive} = 0.9
    snrDet.Pfa (1,1) {mustBeLessThanOrEqual(snrDet.Pfa,1)} = 1e-5
    snrDet.N  (1,1){mustBePositive} = 1
    snrDet.UseMATLAB {mustBeMember(snrDet.UseMATLAB,{'true','false'})} = 'false'
end


if(snrDet.UseMATLAB == "true")
    min_det_snr = shnidman(snrDet.Pd,snrDet.Pfa,snrDet.N,1);
else
    %% Use Shnidmans equation Pg. 581
    % 1. Select a swerling model which is based on how much the targets
    % snr varies from pulse to pulse or cpi to cpi, for a corner reflector I
    % can just use 1
    k_swerling = 1;
    
    % 2. Select an alpha which is based on the pulse detection integrations I
    % need. If 1 CPI then N =1 
    alpha_cpi = 1;
    
    % 3. Select Pd and Pfa, calculate n
    pd = snrDet.Pd;   % probability of detection
    pfa = snrDet.Pfa; % probabiliy of false alarm
    N   = snrDet.N;   % number of pulses
    n = sqrt(-0.8 * log(4 * pfa * (1 - pfa)) + sign(pd - 0.5) *  ...
        sqrt(-0.8 * log(4 * pd  * (1 - pd))));
    
    % 4. Plug in Pd and Pfa to n and X-inf
    x_inf = n * (n + 1 * sqrt(N/2 + (alpha_cpi - 1/4)));
    
    % 5. Compute the series of constants using previously calculated values
    c1 = (((17.7006 * pd - 18.4496) * pd + 14.5339) * pd - 3.525) / k_swerling ;
    
    c2 = (1/k_swerling) * (exp(27.31*pd - 25.14) + (pd - 0.8) * (0.7 * log(10^-5/pfa) + ((2*N - 20)/80)));
    
    c_db = c1 + c2;
    
    c = 10^(c_db/10);
    
    % 6. Calculate chi and convert to power, chi1 is SNR1 in book. 
    chi = (c*x_inf)/N;
    min_det_snr = 10*log10(chi);
    
end
end

