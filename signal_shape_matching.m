window_percentage = 0.033;
num_samples = 1E3; % number of samples within the window
initial_phase_offset = 0.28; % value between 0 and 1 (percentage of the normalised period) indicating the random phase offset of the measured signal
timebase_vector = linspace(initial_phase_offset, initial_phase_offset + window_percentage, num_samples);
signal_amplitued_V = 2E-3;

% signal frequency is normalised
signal = signal_amplitued_V * sin(2 * pi .* timebase_vector);
signal_AC_coupled = signal - mean(signal);

num_test_frequencies = 100;
num_phase_steps = 100;
test_frequency_vector = linspace(0.5, 2, num_test_frequencies); % vector of normalised frequency
results = zeroes(num_test_frequencies, 2);

function result = RMS_error_metric(v1, v2)
    reciprocal_N = 1 / length(v1);
    differences = v1 - v2;
    squared_differences = differences .^ 2;
    result = sqrt(reciprocal_N * sum(squared_differences));
end

function result = cross_correlation_metric(v1, v2)

end

function result = arthurs_metric(v1, v2)

end

for i = 1:num_test_frequencies
    phase_offsets_vector = linspace(0, 1, num_phase_steps);
    for p = phase_offsets_vector
        test_signal = sin(2 * pi * test_frequency_vector(i) .* (timebase_vector + p)); % test signal has normalised magnitude
        test_signal_AC_coupled = test_signal - mean(test_signal);