clear;

sampler = arduino("/dev/ttyACM0", "Uno");
configurePin(sampler, "A0", "AnalogInput");

x_length = 1000;
x_min = 0;
x_max = x_length;

x_points = 0:1:49;
y_vector = zeros(1, 50);

line = animatedline('LineWidth', 2);
axis([x_min, x_max, 0, 1]);
title("Photodiode Output Signal");
xlabel("Sample Number");
ylabel("Voltage (V)");

i = 1;
while i <= x_length
    sample = readVoltage(sampler, "A0");
    addpoints(line, i, sample);
    i = i + 1;
end

while 1
    
    sample = readVoltage(sampler, "A0");
    x_min = x_min + 1;
    x_max = x_max + 1;
    [line_data_x, line_data_y] = getpoints(line);
    line_data_x(x_max) = line_data_x(x_max - 1) + 1;
    line_data_y(x_max) = sample;
    axis([x_min, x_max, 0, 1]);
    addpoints(line, line_data_x(x_max), line_data_y(x_max));
end

