%% Analyzing AoA using multiple antenna elements
% Coherent MIMO radars form the second category and are the focus of this 
% example. A benefit of coherent MIMO radar signal processing is the ability 
% to increase the angular resolution of the physical antenna array by
% forming a virtual array.
fc = 77e9;
c = 3e8;
lambda = c/fc;
Nt = 2;
Nr = 4;

dt = lambda/2;
dr = lambda/2;

txarray = phased.ULA(Nt,dt);
rxarray = phased.ULA(Nr,dr);

ang = -90:90;

pattx = pattern(txarray,fc,ang,0,'Type','powerdb');
patrx = pattern(rxarray,fc,ang,0,'Type','powerdb');
pat2way = pattx+patrx;
figure(1)
ax1 = subplot(1, 2, 1);
helper_plot_multiple_beam_pattern(ang,[pat2way pattx patrx],[-30 0],...
    {'Two-way Pattern','Tx Pattern','Rx Pattern'},...
    'Patterns of full/full arrays - 2Tx, 4Rx',...
    {'-','--','-.'});

% The two-way pattern of this system corresponds to the pattern of a virtual 
% receive array with 2 x 4 = 8 elements. Thus, by carefully choosing the 
% geometry of the transmit and the receive arrays, we can increase the angular
% resolution of the system without adding more antennas to the arrays.

varray = phased.ULA(Nt*Nr,dr);
patv = pattern(varray,fc,ang,0,'Type','powerdb');
ax1 = subplot(1, 2, 2);
helper_plot_multiple_beam_pattern(ang,[pat2way patv],[-30 0],...
    {'Two-way Pattern','Virtual Array Pattern'},...
    'Patterns of thin/full arrays and virtual array',...
    {'-','--'},[1 2]);

