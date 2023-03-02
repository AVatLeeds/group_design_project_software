clear;

c = 299792458;

num_samples = 1E3;


target_range_m = 1;

tune_sweep_period_s = 1E-3;
tune_sweep_Vmax = 5;
tune_sweep_Vmin = 0;
tune_sweep_polarity = -1;

radar_upper_frequency_Hz = 10.527E9;
radar_lower_frequency_Hz = 10.522E9;
radar_centre_frequency_Hz = radar_lower_frequency_Hz + (radar_upper_frequency_Hz / 2);
radar_tunable_bandwidth_Hz = radar_upper_frequency_Hz - radar_lower_frequency_Hz;
radar_tuning_sensitivity_HzperV = -1E6;
radar_output_power_dB = -10;
radar_conversion_efficiency = 1;
radar_chirp_rate = ((tune_sweep_Vmax - tune_sweep_Vmin) * abs(radar_tuning_sensitivity_HzperV)) / tune_sweep_period_s;
% simulate radar beam width and effective gain

target_reflectivity = 1;

%free_space_path_loss_dB = 20 * log10((4 * pi * radar_centre_frequency_Hz) / target_range_m);
free_space_path_loss_dB = 0; % try with no loss to start with
% what is the loss in different substrates - loss vs dielectric constant

received_power_dB = ((radar_output_power_dB - free_space_path_loss_dB) * target_reflectivity) -free_space_path_loss_dB;
received_signal_magnitude = 10 ^ (received_power_dB/ 20);

substrate_dielectric_constant = 1;
propagation_velocity = c / sqrt(substrate_dielectric_constant);
round_trip_time = 2 * (target_range_m / propagation_velocity);
frequency_difference = radar_chirp_rate * round_trip_time;

timebase_vector = linspace(0, tune_sweep_period_s, num_samples);

tune_waveform = timebase_vector .* ((tune_sweep_Vmax - tune_sweep_Vmin) * tune_sweep_polarity) / num_samples;

difference_tone = (received_signal_magnitude / 2) * -cos(2 * pi * frequency_difference .* timebase_vector);

max_range_m = 2;
min_range_m = 0.01;
f_min  = (2 * (min_range_m / propagation_velocity)) * radar_chirp_rate;
f_max  = (2 * (max_range_m / propagation_velocity)) * radar_chirp_rate;
f_test_vector = linspace(f_min, f_max, 100);
test_tone_amplitude = (received_signal_magnitude / 2); % how to actually determine magnitude of test tone?

results = zeros(length(f_test_vector), 2);

for i = 1:length(f_test_vector)
    phase_offsets_vector = linspace(1, (1 / f_test_vector(i)) - tune_sweep_period_s, 100);
    old_max = 0;
    for p = phase_offsets_vector
        test_tone = test_tone_amplitude * sin(2 * pi * f_test_vector(i) .* (timebase_vector + p));
        product = (test_tone - median(test_tone)) .* (difference_tone - median(difference_tone));
        integrator = 0;
        for n = 1:(length(product) - 1)
            integrator = integrator + ((product(n) + product(n + 1)) * (tune_sweep_period_s / num_samples)) / 2;
        end
        if integrator > old_max
            results(i, 1) = integrator;
            results(i, 2) = p;
            old_max = integrator;
        end
    end
end

    