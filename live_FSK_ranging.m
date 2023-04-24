clear;
close all;

tcpip = tcpclient('192.168.0.20', 5555);
writeline(tcpip, "*IDN?");
readline(tcpip)

while 1

writeline(tcpip, ':RUN');
writeline(tcpip, ':SINGle');

writeline(tcpip, ':TRIG:STAT?');
trigger_status = readline(tcpip);
while ~strcmp(trigger_status, "STOP")
    writeline(tcpip, ':TRIG:STAT?');
    trigger_status = readline(tcpip);
end

writeline(tcpip, ':WAV:MODE RAW');
writeline(tcpip, ':WAV:STOP 30000');

writeline(tcpip, ':WAV:SOURce CHAN1');
writeline(tcpip, ":WAV:DATA?");
string = readline(tcpip);
string = convertStringsToChars(string);
ascii_data = string(12:end);

writeline(tcpip, ":WAV:XINC?");
x_increment = str2double(readline(tcpip));
writeline(tcpip, ":WAV:YINC?");
y_increment = str2double(readline(tcpip));

output_waveform_data = zeros(length(ascii_data), 1);

for i = 1:length(ascii_data)
    output_waveform_data(i) = uint8(ascii_data(i));
end

output_waveform_data = output_waveform_data - 128;
output_waveform_data = output_waveform_data * y_increment;

writeline(tcpip, ':WAV:SOURce CHAN2');
writeline(tcpip, ":WAV:DATA?");
string = readline(tcpip);
string = convertStringsToChars(string);
ascii_data = string(12:end);

tune_waveform_data = zeros(length(ascii_data), 1);

for i = 1:length(ascii_data)
    tune_waveform_data(i) = uint8(ascii_data(i));
end

timebase_vector = 0:x_increment:(x_increment * (length(output_waveform_data) - 1));

figure(1);
plot(output_waveform_data, 'color', [0.7, 0.7, 0.7]);
hold on;

% zig-zag filter
for i = 1:(length(output_waveform_data) - 4)
    differences = [(output_waveform_data(i) - output_waveform_data(i + 1)), (output_waveform_data(i + 1) - output_waveform_data(i + 2)), (output_waveform_data(i + 2) - output_waveform_data(i + 3))];
    differences = abs(differences);
    if abs(output_waveform_data(i) - output_waveform_data(i + 3)) < min(differences);
        output_waveform_data(i + 1) = (output_waveform_data(i) + output_waveform_data(i + 3)) / 2;
        output_waveform_data(i + 2) = (output_waveform_data(i) + output_waveform_data(i + 3)) / 2;
    end
end

% spike filter
for i = 1:(length(output_waveform_data) - 3)
    sequence = [output_waveform_data(i), output_waveform_data(i + 1), output_waveform_data(i + 2)];
    sequence = abs(sequence - sequence(1));
    if (sequence(2) > sequence(1)) && (sequence(2) > sequence(3))
        output_waveform_data(i + 1) = (output_waveform_data(i) + output_waveform_data(i + 2)) / 2;
    end
end

plot(output_waveform_data);

differences = zeros(length(tune_waveform_data), 1);
for i = 1:(length(tune_waveform_data) - 1)
    differences(i) = tune_waveform_data(i + 1) - tune_waveform_data(i);
end

transitions = ((normalize(abs(differences))) / 2) .^ 2;

for i = 1:length(transitions)
    if transitions(i) >= 1
        transitions(i) = 1;
    else
        transitions(i) = 0;
    end
end

start = 1;
while transitions(start) ~= 1
    start = start + 1;
end

transitions = transitions(start:end);
output_waveform_data = output_waveform_data(start:end);

gap_widths = 0;
gap = 0;
i = 1;
while i < length(transitions)
    if transitions(i) == 0
        gap = gap + 1;
        i = i + 1;
    else
        gap_widths = [gap_widths, gap];
        gap = 0;
        while transitions(i) == 1
            i = i + 1;
        end
    end
end

gap_widths = sort(gap_widths, 'descend');
start_value = gap_widths(1);
histogram = [start_value; 1];
value_counter = 1;
for i = 2:length(gap_widths)
    if gap_widths(i) == histogram(1, value_counter)
        histogram(2, value_counter) = histogram(2, value_counter) + 1;
    else
        histogram = [histogram, [gap_widths(i); 1]];
        value_counter = value_counter + 1;
    end
end

[temp, order] = sort(histogram(2, :), 'descend');
histogram = histogram(:, order);

width_1 = histogram(1, 1);
width_2 = histogram(1, 2);
sample_margin = 3;

idx = 1;
gap = 0;

% The following was written while very tired and is probably suboptimal
while idx < length(transitions)
    while (transitions(idx) == 1) && (idx < length(transitions))
        gap = 0;
        idx = idx + 1;
    end

    while (transitions(idx) == 0) && (idx < length(transitions))
        gap = gap + 1;
        idx = idx + 1;
    end

    if (abs(gap - width_1) > sample_margin) && (abs(gap - width_2) > sample_margin)
        while (transitions(idx) == 1) && (idx < length(transitions))
            transitions(idx) = 0;
            idx = idx + 1;
        end
        while (transitions(idx) == 0) && (idx < length(transitions))
            idx = idx + 1;
        end
    end
end

waveform_data_1 = 0;
waveform_data_2 = 0;
state = 0;
sequence = 0;
holdoff = 7;
for i = 2:length(transitions)
    if (transitions(i) == 1) && (transitions(i - 1) == 0)
        sequence = sequence((2 + holdoff): (end - holdoff));
        if state
            waveform_data_1 = [waveform_data_1, mean(sequence)];
            %temp = circshift(sequence, 1);
%             mean_diff = mean(sequence - circshift(sequence, 1));
%             temp = sequence(1);
%             for i = 2:length(sequence)
%                 temp = [temp, (temp(i - 1) + mean_diff)];
%             end
%             mean_seq = mean(sequence);
%             for i = 1:length(sequence)
%                 mean_seq = [mean_seq, mean(sequence)];
%             end
%             %temp = (sequence - temp);
%             %temp = temp + mean(sequence);
%             %temp = 0:mean_diff:length(sequence);
%             plot(sequence);
%             hold on;
%             plot(temp);
%             plot(mean_seq);
%             hold off;
%             pause(0.2);
        else
            waveform_data_2 = [waveform_data_2, mean(sequence)];
        end
        sequence = 0;
    elseif transitions(i) == 1
        %average_value = 0;
    elseif (transitions(i) == 0) && (transitions(i - 1) == 1)
        state = ~state;
        sequence = [sequence, output_waveform_data(i)];
    else
        sequence = [sequence, output_waveform_data(i)];
    end
end

min_length = length(waveform_data_1);
if length(waveform_data_2) < min_length
    min_length = length(waveform_data_2);
end
waveform_data_1 = waveform_data_1(2: min_length);
waveform_data_2 = waveform_data_2(2: min_length);
%waveform_data_1 = waveform_data_1 - waveform_data_1(1);
%waveform_data_2 = waveform_data_2 - waveform_data_2(1);

figure(2);
plot(waveform_data_1);
hold on;
plot(waveform_data_2);

indicies = 1:1:length(waveform_data_1);
[fit_1, goodness_of_fit_1] = fit(indicies', waveform_data_1', 'fourier3');
[fit_2, goodness_of_fit_2] = fit(indicies', waveform_data_2', 'fourier3');

plot(fit_1);
plot(fit_2);
hold off;

fit_sampling_indicies = 1:(length(waveform_data_1) / length(output_waveform_data)):length(waveform_data_1);
output_waveform_data_separated_fitted_1 = fit_1(fit_sampling_indicies);
output_waveform_data_separated_fitted_2 = fit_2(fit_sampling_indicies);

figure(1);
hold on;
plot(output_waveform_data_separated_fitted_1);
plot(output_waveform_data_separated_fitted_2);

roll_step = 0;
RMSE_array = [0; 0];

while roll_step < length(output_waveform_data_separated_fitted_1)
    cumulative_sum = 0;
    for i = 1:length(output_waveform_data_separated_fitted_1)
        cumulative_sum = cumulative_sum + ((output_waveform_data_separated_fitted_1(i) - output_waveform_data_separated_fitted_2(i)) ^ 2);
    end
    RMSE_array = [RMSE_array, [sqrt(cumulative_sum / i); roll_step]];
    roll_step = roll_step + 1;
    output_waveform_data_separated_fitted_2 = circshift(output_waveform_data_separated_fitted_2, 1);
end
    
RMSE_array = RMSE_array(:, (2: end));
plot(RMSE_array(1, :));

[temp, order] = sort(RMSE_array(1, :), 'ascend');
RMSE_array = RMSE_array(:, order);

plot(circshift(output_waveform_data_separated_fitted_2, RMSE_array(2, 1)));
hold off;

if RMSE_array(2, 1) > (length(output_waveform_data_separated_fitted_2) / 2)
    phase_delay_steps = length(output_waveform_data_separated_fitted_2) - RMSE_array(2, 1);
else
    phase_delay_steps = RMSE_array(2, 1);
end

phase_delay = y_increment * phase_delay_steps

% shifted_output_waveform_data = circshift(output_waveform_data_separated_fitted_2, RMSE_array(2, 1));
% shifted_output_waveform_data = shifted_output_waveform_data - shifted_output_waveform_data(1);
% 
% figure(3);
% hold on;
% plot(shifted_output_waveform_data);
% plot(output_waveform_data_separated_fitted_1 - output_waveform_data_separated_fitted_1(1));
% plot((output_waveform_data_separated_fitted_1 - output_waveform_data_separated_fitted_1(1)) - shifted_output_waveform_data);

end
