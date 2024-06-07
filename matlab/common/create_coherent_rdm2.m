function [rdm] = create_coherent_rdm2(frameCube)
%CREATE_COHERENT_RDM Summary of this function goes here
%   Detailed explanation goes here
arguments
    frameCube.cube (:,:,:,:){mustBeNonempty} = 0
    frameCube.n_range (1,1){mustBeNonempty} = 0
    frameCube.n_dopp (1,1){mustBeNonempty} = 0
end
beat_signal = frameCube.cube;
n_samples_per_chirp = frameCube.n_range;
n_chirp_per_frame   = frameCube.n_dopp;

%% Window fast time 
win_rng     = kaiser(size(beat_signal, 1),20);
beat_signal = beat_signal .* win_rng ;
% Now, beat_signal contains your signal with the window applied to the Range dimension

%% FFT fast time 
beat_signal = fft(beat_signal, n_samples_per_chirp,1)/size(beat_signal,1);

%% MTI filter accross slow time 
% DC clutter removal filter 
h = [1 -1]; % H(z)  = 1 - z^-1,  H(z)  = 1 - 2z^-1 + z^-2
beat_signal = filter(h,1,beat_signal,[],2);
 
%% Window slow time
win_dop = kaiser(size(beat_signal, 2),20).'; 
beat_signal = win_dop .* beat_signal;
% Now, beat_signal contains your signal with the window applied to the Doppler & Range dimension

%% FFT flow time to create range dopppler response
% A FFT will be run on the beat signal output to generate a range doppler map.

% Range Doppler Map Generation.
% The output of this FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

% Final FFT of slow time dimensions to get doppler data
beat_sig_fftd = fft(beat_signal,n_chirp_per_frame,2)/size(beat_signal,2);

%% Coherently integrate frames

% sum all all 3 frames to improve the SNR of the target
rdm = sum(beat_sig_fftd,4);
end

