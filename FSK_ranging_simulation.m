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

Doppler_frequency = (2 * frequency_1 * target_velocity) / propagation_velocity;

timebase_vector = linspace(0, measurement_time, num_samples);

output_signal = sin(2 * pi * Doppler_frequency .* timebase_vector);
shifted_output_signal = sin(2 * pi * Doppler_frequency .* timebase_vector + (percentage_phase_shift / Doppler_frequency));

plot(timebase_vector, output_signal);
hold;
plot(timebase_vector, shifted_output_signal);