% FSK radar relies on the phase shift that develops between the transmitted and recieved radio signal in the time of flight to the target and back.
% Considering a static target, in the time taken for the radio energy to propogate to the target and back to the reciever, the reciever will see a
% signal that lags the transmitted signal and the amount of this phase lag is directly related to the distance to the target. In this scheme the
% range of the target will be uniquely discernable within half a wavelengths distance from the transmitting antenna.
% If a lower transmitting frequency is used the amount of phase shift a given target range will be a smaller proportion of a full cycle of the wave
% and vice versa for a higher transmitting frequency.
% As in any other heterodyne radio reciever the radar does not measure the recieved signal directly, instead mixing it down to a lower frequency
% that is easier to measure. Simple radars use the same oscillator for transmitting as for the local oscillator to mix down the received signal.
% Therefore, these radars rely on the Doppler effect (caused by the motion of the target objcet) to introduce a frequency difference between the
% transmitted signal and the received signal.
% If the target object is in motion away from the radar then the signal returning will be shifted down in frequency compared to the outgoing signal.
% The reverse is true for an object traveling toward the radar. 
% If the target motion is slow compared to the radio wave speed then in the analysis of the phases of the outgoing and incoming signals it can be
% considered stationary.
% In the round trip time to the target and back the signal will accumulate a total phase offset and will proceed with a constant rate of change in
% phase since the signal is changed in frequency by the Doppler effect. The change in phase over the round trip must somehow be preserved through
% the mixing process - PROVE - so that if the phase of the downconverted signal could be compared with the local oscillator the offset would be
% discernable.
% The concept of FSK ranging relies on the fact that, for two different transmitting frequencies the accumulated phase offset over the round trip
% will be different, and different by an amount that corresponds to the target range. If the phase offsets are indeed carried through the
% downconversion process, then the same phase difference will be present between the downconverted signals at the two different operating
% frequencies. And thus, the measurement of this phase difference should determine the range to the target object

% How to accurately determine the phase between the two downconverted signals?
% The issues to contend with are that the the exact frequency of the downconverted signal will vary slightly over the measurement window due to
% natural variations in the target velocity, the magnitudes of the two signals may be different, the signals may have a static offset with respect
% to each other and the magnitudes and offsets of the two signals may change within the measurement window.

clear;

c = 299792458;

num_samples = 10E3;
measurement_time = 2;


target_range_m = 1;
target_velocity_m_per_s = 0.010

tune_frequency_Hz = 1E3;
tune_Vmax = 5;
tune_Vmin = 0;
tune_sweep_polarity = -1;

radar_upper_frequency_Hz = 10.527E9;
radar_lower_frequency_Hz = 10.522E9;
radar_centre_frequency_Hz = radar_lower_frequency_Hz + (radar_upper_frequency_Hz / 2);
radar_tunable_bandwidth_Hz = radar_upper_frequency_Hz - radar_lower_frequency_Hz;
radar_tuning_sensitivity_HzperV = -1E6;
radar_output_power_dB = -10;
radar_conversion_efficiency = 1;

frequency_1 = radar_upper_frequency_Hz + radar_tuning_sensitivity_HzperV * tune_Vmin;
frequency_2 = radar_upper_frequency_Hz + radar_tuning_sensitivity_HzperV * tune_Vmax;

substrate_dielectric_constant = 1;
propagation_velocity = c / sqrt(substrate_dielectric_constant);

frequency_difference = abs(frequency_1 - frequency_2);
percentage_phase_shift = (propagation_velocity / frequency_difference) / (2 * target_range_m);

Doppler_frequency = (2 * frequency_1 * target_velocity_m_per_s) / propagation_velocity;

timebase_vector = linspace(0, measurement_time, num_samples);

output_signal = sin(2 * pi * Doppler_frequency .* timebase_vector);
shifted_output_signal = sin(2 * pi * Doppler_frequency .* timebase_vector + (percentage_phase_shift / Doppler_frequency));

plot(timebase_vector, output_signal);
hold;
plot(timebase_vector, shifted_output_signal);