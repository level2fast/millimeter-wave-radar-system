# **People Detection using Millimeter Wave Radar**  

![GitHub License](https://img.shields.io/github/license/level2fast/millimeter-wave-radar-system)<br/>
![GitHub contributors](https://img.shields.io/github/contributors/level2fast/millimeter-wave-radar-system) <br/>
![GitHub top language](https://img.shields.io/github/languages/top/level2fast/millimeter-wave-radar-system)<br/>
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/level2fast/millimeter-wave-radar-system) <br/>
![GitHub repo size](https://img.shields.io/github/repo-size/level2fast/millimeter-wave-radar-system)<br/>

## **📝 Project Description** 
This project consists of a a simulation of an FMCW Millimeter wave radar system that was developed to confirm that the selected radar parameters were appropriate for detecting the range and velocity of a person. The simulation was then used to produce a model capable of processing radar data captured by the IWR6843A0P. Radar signal processing analysis was performed using MATLAB. The SoC application deployed to the chip was configured to perform range doppler process, but the code itself was provided by Texas Instruments. 

A moving target indicator radar signal data processing chain was implemented in MATLAB to peform analysis of the data. Finally a C application provided by Texas Instruments was compiled and deployed to the **[IWR6843A0P](https://www.ti.com/tool/IWR6843AOPEVM#description)** MCU and DSP to process the data in real time producing the necessary outputs that are provided as input to the radar visualizer. The overall objective of this project was the production of a range doppler map which shows how far a moving target is from the radar in meters and the velocity at which it is moving in meters per second. As a bonus angle of arrival was also estimated with limited accuracy due to a small number of antenna elements and the selected method of beamforming.

A visualizer that executes on an android device was developed to see the results in near real time. The visualizer was developed using the Flutte framework.

# MTI Data Processing Chain
<img src="docs/images/MTI-Data-Proc-Chain-HW-SP.png"/>

---

## **🚀 Live Demo**  
[🔗 Click here to check out the live version](https://github.com/level2fast/millimeter-wave-radar-system/blob/main/visualizer/README.md#people-detection-mobile-device-visualizer-output) *(if applicable)*  


[🔗 Click here to view the final presentation](https://drive.google.com/file/d/1-2rGQtX42mz8FN6Se58B0nz1l1jNucHP/view?usp=sharing)
<br />

<!-- ---

## **📸 Screenshots**  
Include relevant screenshots or GIFs showcasing your project’s interface and functionality.  

![Screenshot](https://your-screenshot-url.com/image.png)   -->

---

## **🛠️ Features**  
✅ Feature 1 – *Data Generation of moving targets using FMCW Radar simulation* <br/>
✅ Feature 2 – *Range Doppler processing of simulated moving targets*<br/> 
✅ Feature 3 – *Range Doppler processing of I/Q data captured by SoC*<br/> 
✅ Feature 4 – *Custom CFAR Algorithm*<br/> 
✅ Feature 5 – *Angle of Arrival processing*<br/> 
✅ Feature 6 – *RadarVision mobile application for observing moving targets in near real time*<br/>   

---

## **📦 Tech Stack**  
- **Languages:** MATLAB, C, Dart
- **Backend:** Python, Flutter  
- **Database:** FireBase Realtime Database
- **Tools & CI/CD:** Git
- **Hardware:** TI-IWR6843AOP, TI-DCA1000EVM

<!-- ---

## **📥 Installation & Setup**  
Clone the repository and install dependencies:  

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
npm install -->
