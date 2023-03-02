clear;

tcpip = tcpclient('192.168.0.20', 5555);
query(tcpip, "*IDN?")

string = query(tcpip, ":WAV:DATA?");
ascii_data = string(12:end);

x_increment = str2double(query(tcpip, ":WAV:XINC?"));
y_increment = str2double(query(tcpip, ":WAV:YINC?"));

data = zeros(length(ascii_data), 1);

for i = 1:length(ascii_data)
    data(i) = uint8(ascii_data(i));
end

data = data - 127;
data = data * y_increment * 1000;
data = data(1:end - 1);
timebase_vector = 0:x_increment:(x_increment * (length(data) - 1));

plot(timebase_vector, data);
title("Oscilloscope Waveform Captured Over LXI");
ylabel("Voltage (mV)");
xlabel("time (s)");


