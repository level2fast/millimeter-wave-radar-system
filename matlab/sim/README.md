# SFND Radar Target Generation and Detection
#### Udacity Sensor Fusion Nanodegree 
Configuring the radar FMCW waveform based on the system requirements and simulating the radar signal propagation and moving target scenario. Finally, post processing the radar signal using 1st FFT, 2nd FFT, and CA-CFAR to estimate the target's range and velocity.
___
### Project Flow Chart
<img src="./Assets/Project flow chart.png"/>

---

### 1. Simulation steps
	1. Create target data
	2. Create noise data
	3. Create datacube by combining target data + noise data
	4. Create RDM map by applying match filter to data

### 4. Signal generation and Moving Target simulation
TODO SDD: Redo this diagram and use a graphic with a person and a complex exponential with quadratic phase for tx and rx.
<img src="./Assets/Signal propagation model.png"/>

### 5. Range Measurement
Applying the Fast Fourier Transform on the sampled beat signal to convert the signal from time domain to frequency domain and hence know the range between the target and the radar.
<p align="center">
  <img src="./Assets/FastFourierTransform.png"/>
</p>

### 1. Radar Specifications 
* Frequency of operation = 77GHz
* Max Range = 200 m
* Range Resolution = 1 m
* Max Velocity = 100 m/s
* Light Speed = 3e8 m/s

### 2. User Defined Range and Velocity of the simulated target

* Target Initial Range = 100 m
* Target Velocity = 50 m/s


### 3. FMCW Waveform Generation
The FMCW waveform design:
* carrier frequency = 77 GHz
* The Bandwidth (B) = speed_of_light / (2 * Range_Resolution_of_Radar) = 150 MHz
* Chirp Time (Tchirp) =  (sweep_time_factor(should be at least 5 to 6) * 2 * Max_Range_of_Radar) / speed_of_light = 7.333 μs
* Slope of the FMCW chirp = B / Tchirp = 2.045e+13
* The number of chirps in one sequence (Nd) = 128
* The number of samples on each chirp (Nr) =1024 


* Simulation Result
<img src="Results/Range from FFT applied on the beat signal.jpg"/>

### 6. Range Doppler Response
Applying the 2D FFT on the beat signal where the output of the first FFT gives the beat frequency, amplitude, and phase for each target. This phase varies as we move from one chirp to another due to the target’s small displacements. Once the second FFT is implemented it determines the rate of change of phase, which is nothing but the doppler frequency shift (Velocity of the targets). The output of Range Doppler response represents an image with Range on one axis and Doppler on the other. This image is called as Range Doppler Map (RDM).

* Simulation Result
<img src="Results/Range doppler map from 2D FFT .jpg"/>

