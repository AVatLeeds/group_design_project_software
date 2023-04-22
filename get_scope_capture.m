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

figure(1);
hold off;
plot(timebase_vector, output_waveform_data);
title("Oscilloscope Waveform Captured Over LXI");
ylabel("Voltage (mV)");
xlabel("time (s)");

end
