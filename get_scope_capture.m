clear;

tcpip = tcpclient('10.42.0.84', 5555);
writeline(tcpip, "*IDN?");
readline(tcpip)

writeline(tcpip, ':RUN');
writeline(tcpip, ':SINGle');

writeline(tcpip, ':TRIG:STAT?');
trigger_status = readline(tcpip)
while ~strcmp(trigger_status, "STOP")
    writeline(tcpip, ':TRIG:STAT?');
    trigger_status = readline(tcpip)
end

writeline(tcpip, ':WAV:MODE RAW');
writeline(tcpip, ':WAV:STOP 500000');

writeline(tcpip, ":WAV:DATA?");
string = readline(tcpip);
string = convertStringsToChars(string);
ascii_data = string(12:end);

writeline(tcpip, ":WAV:XINC?");
x_increment = str2double(readline(tcpip));
writeline(tcpip, ":WAV:YINC?");
y_increment = str2double(readline(tcpip));

data = zeros(length(ascii_data), 1);

for i = 1:length(ascii_data)
    data(i) = uint8(ascii_data(i));
end

data = data - 128;
data = data * y_increment;
data = data(1:end - 1);

timebase_vector = 0:x_increment:(x_increment * (length(data) - 1));

plot(timebase_vector, data);
title("Oscilloscope Waveform Captured Over LXI");
ylabel("Voltage (mV)");
xlabel("time (s)");

difference = zeros(length(data), 1);
for i = 1:(length(data) - 1)
    difference(i) = data(i + 1) - data(i);
end

hold
plot(timebase_vector, difference);
