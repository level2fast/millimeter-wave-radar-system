# millimeter-wave-radar-system
Welcome to the people detection radar system repo! This repo contains code and files needed to build a millimeter wave radar system capable of detecting range and doppler of a human target using the **[IWR6843A0P](https://www.ti.com/tool/IWR6843AOPEVM#description)** System on a Chip(SoC). The radar signal processing analysis was performed using MATLAB. A simulation of an FMCW radar system was developed to confirm that the selected radar parameters were appropriate for the desired application of the radar system. That simulation was then used to produce a production model capable of processing radar data captured by the **[IWR6843A0P](https://www.ti.com/tool/IWR6843AOPEVM#description)**. A moving target indicator radar signal data processing chain was implemented in MATLAB to peform analysis of the data. Finally a C application was compiled and deployed to the **[IWR6843A0P](https://www.ti.com/tool/IWR6843AOPEVM#description)** MCU and DSP to process the data in real time producing the necessary outputs that are provided as input to the radar visualizer. The overall objective of this project was the production of a range doppler map which shows how far a moving target is from the radar in meters and the velocity at which it is moving in meters per second. As a bonus angle of arrival was also estimated with limited accuracy due to a small number of antenna elements and the selected method of beamforming.

# MTI Data Processing Chain
<img src="docs/images/MTI-Data-Proc-Chain-HW-SP.png"/>

## Project Folders
### docs
This folder contains the project specification document as diagrams.<br />
docs<br />
┣ images<br />
┃ ┣ FastFourierTransform.png<br />
┃ ┣ fmcw-range-sim-measurment.png<br />
┃ ┣ fmcw-sim-capture.png<br />
┃ ┣ Project flow chart.png<br />
┃ ┣ Screenshot 2024-05-18 133608-range-eq.png<br />
┃ ┗ Signal propagation model.png<br />
┣ project_specification<br />
┃ ┣ img<br />
┃ ┃ ┗ ucsd_logo.jpg<br />
┃ ┣ tex<br />
┃ ┃ ┗ doc.tex<br />
┃ ┣ .gitignore<br />
┃ ┣ Makefile<br />
┃ ┣ project_specification.aux<br />
┃ ┣ project_specification.log<br />
┃ ┣ project_specification.out<br />
┃ ┣ project_specification.pdf<br />
┃ ┣ project_specification.toc<br />
┃ ┗ texput.log<br />
┗ .gitkeep
### matlab
This folder contains matlab scripts that model and simulate an FMCW radar capable of detecting a human target in range and doppler.<br />
matlab<br />
 ┣ common<br />
 ┃ ┣ fmcw<br />
 ┃ ┃ ┣ calc_fmcw_angle_fft.m<br />
 ┃ ┃ ┣ calc_fmcw_angular_res.m<br />
 ┃ ┃ ┣ calc_fmcw_max_range.m<br />
 ┃ ┃ ┣ calc_fmcw_max_range_snr_det.m<br />
 ┃ ┃ ┣ calc_fmcw_max_velocity.m<br />
 ┃ ┃ ┣ calc_fmcw_max_velocity_res.m<br />
 ┃ ┃ ┣ create_fmcw_vectors.m<br />
 ┃ ┃ ┗ get_aoa_vector.m<br />
 ┃ ┣ auto_correlation.m<br />
 ┃ ┣ calc_dopp_params.m<br />
 ┃ ┣ calc_min_snr_det.m<br />
 ┃ ┣ calc_min_tgt_det_rng.m<br />
 ┃ ┣ calc_n_pulse_per_cpi.m<br />
 ┃ ┣ calc_n_samp_per_pulse.m<br />
 ┃ ┣ calc_rel_vel_and_rng.m<br />
 ┃ ┣ calc_tgt_snr.m<br />
 ┃ ┣ calc_trgt_prob_det.m<br />
 ┃ ┣ calc_unamb_rng.m<br />
 ┃ ┣ calc_unamb_vel.m<br />
 ┃ ┣ cfar_2d_rdm.m<br />
 ┃ ┣ compress_signal.m<br />
 ┃ ┣ create_coherent_data.m<br />
 ┃ ┣ create_coherent_rdm.m<br />
 ┃ ┣ create_coherent_rdm2.m<br />
 ┃ ┣ create_complex_slow_time_vec.m<br />
 ┃ ┣ create_fast_time_freq.m<br />
 ┃ ┣ create_lfm_pulse_samples.m<br />
 ┃ ┣ create_lfm_pulse_time.m<br />
 ┃ ┣ create_range_migrated_data.m<br />
 ┃ ┣ create_signal_data.m<br />
 ┃ ┣ create_vectors.m<br />
 ┃ ┣ cross_correlation.m<br />
 ┃ ┣ match_filter_signal.m<br />
 ┃ ┗ remove_range_migration.m<br />
 ┣ data<br />
 ┃ ┗ adc_data.bin<br />
 ┣ sim<br />
 ┃ ┣ aoa_sim.m<br />
 ┃ ┣ beam_pattern_sim.m<br />
 ┃ ┣ calc_aoa_in_meters.m<br />
 ┃ ┣ cfar_2d_rdm_sim.m<br />
 ┃ ┣ cfar_ca_sim.m<br />
 ┃ ┣ cfar_example.m<br />
 ┃ ┣ helper_plot_multiple_beam_pattern.m<br />
 ┃ ┣ iwr6843aop_phased_tlbx_radar_sim.m<br />
 ┃ ┣ iwr6843aop_radar_sim.m<br />
 ┃ ┣ mti.m<br />
 ┃ ┣ music_alg_aoa_sim.m<br />
 ┃ ┣ prf_example.m<br />
 ┃ ┣ Radar.m<br />
 ┃ ┣ radar_simulation.slx<br />
 ┃ ┣ README.m<br />
 ┃ ┗ Target.m<br />
 ┣ util<br />
 ┃ ┗ read_dca_1000.m<br />
 ┣ visualizer<br />
 ┃ ┣ README.md<br />
 ┃ ┗ visualizer.m<br />
 ┣ FmcwRadar.m<br />
 ┣ process_iwr6843aop_data.m<br />
 ┗ README.md<br />
### src
This folder contains c source codes used for building and application that execute on the IWR6843AOP SoC.<br />
src<br />
 ┣ .launches<br />
 ┃ ┗ out_of_box_6843_aop.launch<br />
 ┣ .settings<br />
 ┃ ┣ org.eclipse.cdt.codan.core.prefs<br />
 ┃ ┣ org.eclipse.cdt.debug.core.prefs<br />
 ┃ ┗ org.eclipse.core.resources.prefs<br />
 ┣ configuration_profiles<br />
 ┃ ┣ xwr68xx_AOP_profile_2024_05_11T23_47_56_599.cfg<br />
 ┃ ┗ xwr68xx_AOP_profile_static_clutter_reduced.cfg<br />
 ┣ src<br />
 ┃ ┣ sysbios<br />
 ┃ ┃ ┣ makefile<br />
 ┃ ┃ ┗ sysbios.aer4ft<br />
 ┃ ┣ .exclude<br />
 ┃ ┗ makefile.libs<br />
 ┣ .ccsproject<br />
 ┣ .cproject<br />
 ┣ .gitignore<br />
 ┣ .project<br />
 ┣ .xdchelp<br />
 ┣ antenna_geometry.c<br />
 ┣ data_path.c<br />
 ┣ main.c<br />
 ┣ mmw.cfg<br />
 ┣ mmwdemo_adcconfig.c<br />
 ┣ mmwdemo_flash.c<br />
 ┣ mmwdemo_monitor.c<br />
 ┣ mmwdemo_rfparser.c<br />
 ┣ mmw_cli.c<br />
 ┣ mmw_lvds_stream.c<br />
 ┣ objectdetection.c<br />
 ┗ XDS110.ccxml<br />
### util
This folder contains small utility programs used to assit in testing the radar system. <br />
arduino<br />
 ┣ ble_motor_conrol<br />
 ┃ ┗ ble_motor_conrol.ino<br />
 ┗ MotorControl<br />
 ┃ ┗ ble_motor_conrol.ino<br />

# People Detection Radar Presentation
The following links contain presentations demonstrating the various phases of development for the People Detection project. The 1st presentation provides an overview of the project and each sprint presentation highlights accomplishments we've made through each phase of development up to project completion
<br />
<br />
[64GHz People Detection Radar](https://docs.google.com/presentation/d/1UIobzvt940PiRzJJoqzG_jstFSM7m4pV/edit?usp=drive_link&ouid=112085791097240071479&rtpof=true&sd=true)
<br />
[Sprint 1](https://docs.google.com/presentation/d/17Z4IEgLOOTPaDsA3-klGJfAxYMCZCAKe/edit?usp=drive_link&ouid=112085791097240071479&rtpof=true&sd=true)
<br />
[Sprint 2](https://docs.google.com/presentation/d/12oHWV6L4Eyr7IAybFQ9ZD15lLnU75F-t/edit?usp=drive_link&ouid=112085791097240071479&rtpof=true&sd=true)
<br />
[Sprint 3](https://docs.google.com/presentation/d/18pwAkHE_p4_Qab5gMU5JxtgKBYnQPv2Z/edit?usp=drive_link&ouid=112085791097240071479&rtpof=true&sd=true)
<br />
[Sprint 4](https://docs.google.com/presentation/d/182JTYqSuuebc5cSZfN3FYDypfgK6dsb8/edit?usp=drive_link&ouid=112085791097240071479&rtpof=true&sd=true)
<br />
[Sprint 5](https://docs.google.com/presentation/d/1BEKzpFS6jXvX48bXmcZpeML1otvU0zG0/edit?usp=drive_link&ouid=112085791097240071479&rtpof=true&sd=true)
<br />
[Sprint 6](https://docs.google.com/presentation/d/1BQ_VSe1GsIoxJrYLUMS8agz4udzsNNxs/edit?usp=drive_link&ouid=112085791097240071479&rtpof=true&sd=true)
<br />
[Sprint 7](https://docs.google.com/presentation/d/1vSYEG_gKn_QH3Cs1vhudIISilF88ROOK/edit?usp=sharing&ouid=112085791097240071479&rtpof=true&sd=true)
<br />
<br />
[Final Presentation](https://drive.google.com/file/d/1-2rGQtX42mz8FN6Se58B0nz1l1jNucHP/view?usp=sharing)
<br />



