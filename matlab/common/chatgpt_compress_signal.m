function compressed_signal = chatgpt_compress_signal(signal, fs, fc, T, f_bw)
    % Inputs:
    %   - signal: Received radar signal in the time domain.
    %   - fs: Sampling frequency of the radar signal.
    %   - fc: Center frequency of the LFM chirp waveform.
    %   - T: Pulse duration (in seconds).
    %   - f_bw: Chirp bandwidth (in hertz).

    % Calculate the chirp rate
    k = f_bw / T;

    % Generate the reference chirp signal
    t = 0:1/fs:T-1/fs;
    reference_chirp = exp(1i * pi * k * (t - T/2).^2);

    % Matched filtering using FFT
    signal_freq = fft(signal);
    reference_freq = fft(reference_chirp);

    % Perform element-wise multiplication in the frequency domain
    compressed_freq =  conj(reference_freq) * signal_freq ;

    % Inverse FFT to obtain the time-domain result
    compressed_signal = ifft(compressed_freq);

    % Shift the result to center it
    compressed_signal = fftshift(compressed_signal);

    % Optionally, normalize the compressed signal
    compressed_signal = compressed_signal / max(abs(compressed_signal));
end
