% This script provides and example that demonstrates the effect of PRF on a
% radar.

prf_vec_hz = [2, 4, 8, 16, 32, 50, 60, 64, 95,100, 101, 128, 150, 200, 228]*1e3;
target_velocity_mps = -750;
radar_freq_hz = 10e9;
wavelength_m = (physconst('LightSpeed')/radar_freq_hz);
range_rate_to_dop = -2/wavelength_m;
dopp_freq = (-2*target_velocity_mps)/wavelength_m;

k = round(dopp_freq ./ prf_vec_hz); % k is the ambiguity index and it describes 
                                    % how man PRI's we have to wait before receiving a return

dopp_freq_ambig = dopp_freq - (k.*prf_vec_hz);
range_rate_apparent = dopp_freq_ambig / range_rate_to_dop; % This is the doppler value of the 
                                                           % target as it appears to the radar 
                                                           % at each PRF

figure()
plot(prf_vec_hz/1e3,range_rate_apparent,'o-')
yline(target_velocity_mps,'--','Target');
xlabel('PRF [kHz]')
ylabel('Range Rate [m/sec]')
title(sprintf(['Apparent Target Range Rate vs. PRF \n$\\dot{R}$ = %2.2f m/s, $f_c$ = %2.2f GHz'],target_velocity_mps,radar_freq_hz/1e9),'Interpreter','latex');
for i = 1:length(prf_vec_hz)
    fprintf(1,'PRF\n\t%2.2f KHz\n',prf_vec_hz(i)/1e3);                             
    fprintf(1,'Target Doppler ambiguous \n\t%2.2f Khz\n',dopp_freq_ambig(i)/1e3);
    fprintf(1,'Target Doppler Frequency \n\t%2.2f Khz\n',dopp_freq/1e3);
    fprintf(1,'Target Velocity apparent  \n\t%2.2f m/sec\n',range_rate_apparent(i));
    fprintf(1,'Target Velocity \n\t%2.2f m/sec\n',target_velocity_mps);
    fprintf(1,'------------------------------------\n\n');
end                                                       


