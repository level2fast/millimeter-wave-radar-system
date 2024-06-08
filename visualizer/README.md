# MATLAB Visualizer
A Range-Doppler map visualizer is a tool used primarily in radar systems to display the data captured by the radar. It presents a two-dimensional representation where one axis represents the range (distance) to a target and the other axis represents the Doppler shift (relative velocity) of the target.

# Detailed breakdown of range doppler map components
## Range Axis
This axis represents the distance from the radar to the target. It is usually displayed in meters or kilometers.
The range information is obtained by measuring the time delay between the transmission of a radar pulse and the reception of the echo from the target.

## Doppler Axis
This axis represents the relative velocity between the radar and the target. It is often displayed in meters per second or kilometers per hour.
The Doppler shift is calculated based on the change in frequency of the returned radar signal due to the relative motion of the target.

## Amplitude/Intensity:
The amplitude or intensity of the signal at each range-Doppler coordinate can be represented using colors or grayscale, indicating the strength of the returned signal.
Brighter or more intense colors typically represent stronger reflections, which can indicate larger or more reflective targets.

# Functionality
## Target Detection
The visualizer helps in identifying targets within the radar's range and estimating their relative speed. Stationary targets will appear along the zero Doppler axis, while moving targets will shift along the Doppler axis based on their relative velocity.

 How To Run

1. The IWR6843AOPEVM must be running the out-of-box (OOB) demo. This can be achieved by either flashing the pre-built binaries from Texas Instruments or using Code Composer Studio to build the code and load it onto the board over the MMWAVEICBOOST
JTAG connection; instructions for both methods can be found [here](https://dev.ti.com/tirex/explore/node?node=A__ADFsv62CVEotGtkwF2Zxlg__radar_toolbox__1AslXXD__LATEST).

2. Once the board is loaded with the code and powered on via a connection to the host PC over USB, use Device Manager to identify the data COM port and the control COM port. Both ports should appear as COM ports in device manager; if the board is
connected directly (i.e. not through a carrier card), the control port is the 'Enhanced' port and the data port is the 'Standard' port. If connected via the MMWAVEICBOOST, the ports should be directly labeled as Application and Data.

3. Use your favorite serial terminal emulator (TeraTerm is recommended) to connect to the control COM port at a baud rate of 115200 with no parity, no stop bit, 1 start bit, and no flow control. If everything is configured correctly, you should
be greeted with a command line prompt. If you instead see a quickly-scrolling wall of random ASCII, you are likely connected to the data port instead of the control port.

4. Configure the radar; this can be done by manually entering the necessary commands, or simply copy-pasting a list of them into the terminal. Pre-made lists of commands with reasonable parameters are available in the `configuration_profiles` subdirectory
of the `src` directory. Simply copy and paste the non-comment lines into the CLI to execute them in sequence. Note that you may need to configure your terminal emulator to insert a delay after each character if the radar has issues processing the commands
when copy-pasting. This can be done in TeraTerm using the 'delay after character' and 'delay after line' settings. A delay of 10 ms and 100 ms respectively is recommended. An example configuration is below

    ```
    % ***************************************************************
    % Created for SDK ver:03.06
    % Created using Visualizer ver:3.6.0.0
    % Frequency:60
    % Platform:xWR68xx_AOP
    % Scene Classifier:best_range_res
    % Azimuth Resolution(deg):30 + 30
    % Range Resolution(m):0.044
    % Maximum unambiguous Range(m):9.02
    % Maximum Radial Velocity(m/s):1
    % Radial velocity resolution(m/s):0.13
    % Frame Duration(msec):250
    % RF calibration data:None
    % ***************************************************************
    sensorStop
    flushCfg
    dfeDataOutputMode 1
    channelCfg 15 7 0
    adcCfg 2 1
    adcbufCfg -1 0 1 1 1
    profileCfg 0 60 359 7 57.14 0 0 70 1 256 5209 0 0 158
    chirpCfg 0 0 0 0 0 0 0 1
    chirpCfg 1 1 0 0 0 0 0 2
    chirpCfg 2 2 0 0 0 0 0 4
    frameCfg 0 2 16 0 250 1 0
    lowPower 0 0
    guiMonitor -1 1 1 0 0 1 0
    cfarCfg -1 0 2 8 4 3 0 24 1
    cfarCfg -1 1 0 4 2 3 1 15 1
    multiObjBeamForming -1 1 0.5
    clutterRemoval -1 1
    calibDcRangeSig -1 0 -5 8 256
    extendedMaxVelocity -1 0
    lvdsStreamCfg -1 0 0 0
    compRangeBiasAndRxChanPhase 0.0 1 0 -1 0 1 0 -1 0 1 0 -1 0 1 0 -1 0 1 0 -1 0 1 0 -1 0
    measureRangeBiasAndRxChanPhase 0 1.5 0.2
    CQRxSatMonitor 0 3 5 121 0
    CQSigImgMonitor 0 127 4
    analogMonitor 0 0
    aoaFovCfg -1 -90 90 -90 90
    cfarFovCfg -1 0 0 8.92
    cfarFovCfg -1 1 -1 1.00
    calibData 0 0 0
    bpmCfg -1 0 0 0
    sensorStart
    ```

5. Note that you can generate your own configuration profile using TI's mmWave demo online; simply export the profile to get the CLI commands to execute. Be aware that for the visualizer to fully function, the output in the demo for the 3D scatterplot, range-Doppler
heat map, and static range profile must be enabled.

6. Verify the response to the `sensorStart` command is success. If the CLI issues an error about the configuration being incomplete, you may have a slightly different version of the OOB firmware loaded that requires more parameters. In that case it
is recommended you use the mmWave demo to generate a profile suitable for your firmware version.

7. Once the radar is running, open the visualizer script in Matlab. Change the COM port in the script's call to `serialport` to match the data COM port of your radar. Then simply run the script.

# People Detection MATLAB Visualizer Output
<img src="/docs/images/rdm-no-static-clutter.png"/>

# People Detection Mobile Device Visualizer Output
Test Scenario              |  RadarVision Mobile App
:-------------------------:|:-------------------------:
![](/docs/images/test.gif)  |  ![](/docs/images/rng-vel-plot-mobile-dev.gif)

