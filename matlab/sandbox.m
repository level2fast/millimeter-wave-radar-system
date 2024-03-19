x = cos(2*pi*0:100);
% Assuming you have your signal in `x`
N = length(x); % Length of signal
fs = 1000; % Sampling frequency in Hz
X_fft = fft(x, N); % Compute FFT

% Generate frequency vector for plotting
f = (0:N-1)*(fs/N); % Full frequency axis
normalized_frequency_full = f / (fs/2); % Normalize by Nyquist frequency

% Plot only the first half (since FFT is symmetric for real signals)
plot(normalized_frequency_full(1:N/2), abs(X_fft(1:N/2)));
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude');
