clear;
close all;

tcpip = tcpclient('192.168.0.20', 5555);
writeline(tcpip, "*IDN?");
readline(tcpip)

while 1

writeline(tcpip, ':RUN');
writeline(tcpip, ':SINGle');

writeline(tcpip, ':TRIG:STAT?');
trigger_status = readline(tcpip)
while ~strcmp(trigger_status, "STOP")
    writeline(tcpip, ':TRIG:STAT?');
    trigger_status = readline(tcpip)
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

%tune_waveform_data = tune_waveform_data - 128;
%tune_waveform_data = tune_waveform_data * y_increment;

timebase_vector = 0:x_increment:(x_increment * (length(output_waveform_data) - 1));

figure(1);
hold off;
plot(timebase_vector, output_waveform_data);
title("Oscilloscope Waveform Captured Over LXI");
ylabel("Voltage (mV)");
xlabel("time (s)");

difference = zeros(length(output_waveform_data), 1);
for i = 1:(length(output_waveform_data) - 1)
    difference(i) = output_waveform_data(i + 1) - output_waveform_data(i);
end

hold on;
plot(timebase_vector, difference);

value_idx = 1;
hist = [tune_waveform_data(1); 1];
for i = 2:length(tune_waveform_data)
    found = 0;
    for v = 1:value_idx
        if tune_waveform_data(i) == hist(1, v);
            hist(2, v) = hist(2, v) + 1;
            found = 1;
        end
    end
    if ~found
        value_idx = value_idx + 1;
        hist = [hist, [tune_waveform_data(i); 1]];
    end
end

hist = hist';
hist = sortrows(hist, -2);
hist = hist(1:2, 1:end);
hist = sortrows(hist, -1);

upper_lim = hist(1, 1);
lower_lim = hist(2, 1);

for i = 1:length(tune_waveform_data)
    if tune_waveform_data(i) > upper_lim
        tune_waveform_data(i) = upper_lim;
    elseif tune_waveform_data(i) < lower_lim
        tune_waveform_data(i) = lower_lim;
    end
end

midpoint = lower_lim + ((upper_lim - lower_lim) / 2);


% run to first switch between f1 and f2
offset = 1;
if tune_waveform_data(offset) > midpoint
    while tune_waveform_data(offset) > midpoint
        offset = offset + 1;
    end
elseif tune_waveform_data(offset) < midpoint
    while tune_waveform_data(offset) < midpoint
        offset = offset + 1;
    end
end

waveform_f1 = 0;
timebase_f1 = 0;
idx = 1;
i = offset;
while i < length(tune_waveform_data)
    if tune_waveform_data(i) < midpoint
        i = i + 1; %increment to discard sample directly at switch from f1 to f2
        start = i;
        average_value = output_waveform_data(i);
        i = i + 1;
        if (i > length(tune_waveform_data))
            break;
        end
        while tune_waveform_data(i) < midpoint
            average_value = (average_value + output_waveform_data(i)) / 2;
            i = i + 1;
            if (i >= length(tune_waveform_data))
                break;
            end
        end
        timepoint = timebase_vector(start + round((i - start - 1) / 2));
        waveform_f1(idx) = average_value;
        waveform_f1 = [waveform_f1, 0];
        timebase_f1(idx) = timepoint;
        timebase_f1 = [timebase_f1, 0];
        idx = idx + 1;
    end
    i = i + 1;
end
waveform_f1 = waveform_f1(1:(end - 1));
timebase_f1 = timebase_f1(1:(end - 1));

waveform_f2 = 0;
timebase_f2 = 0;
idx = 1;
i = offset;
while i < length(tune_waveform_data)
    if tune_waveform_data(i) > midpoint
        i = i + 1; %increment to discard sample directly at switch from f1 to f2
        start = i;
        average_value = output_waveform_data(i);
        i = i + 1;
        if (i >= length(tune_waveform_data))
            break;
        end
        while tune_waveform_data(i) > midpoint
            average_value = (average_value + output_waveform_data(i)) / 2;
            i = i + 1;
            if (i >= length(tune_waveform_data))
                break;
            end
        end
        timepoint = timebase_vector(start + round((i - start - 1) / 2));
        waveform_f2(idx) = average_value;
        waveform_f2 = [waveform_f2, 0];
        timebase_f2(idx) = timepoint;
        timebase_f2 = [timebase_f2, 0];
        idx = idx + 1;
    end
    i = i + 1;
end
waveform_f2 = waveform_f2(1:(end - 1));
timebase_f2 = timebase_f2(1:(end - 1));

% offset output waveforms from f1 and f2 so they both start from zero
waveform_f1 = waveform_f1 - waveform_f1(1);
waveform_f2 = waveform_f2 - waveform_f2(1);

figure(2);
hold off;
plot(timebase_f1, waveform_f1);
hold on;
plot(timebase_f2, waveform_f2);

end






%hold off
%plot(timebase_vector, tune_waveform_data)
