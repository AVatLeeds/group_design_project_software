clear;
close all;

max_distance_mm = 750;
min_distance_mm = 50;
centre_distance_offset_mm = 34;
search_angle_deg = 60;
max_width_mm = 2 * max_distance_mm * cos(deg2rad(search_angle_deg / 2)) * tan(deg2rad(search_angle_deg / 2));

radius_step_mm = 50;
arc_length_step_min_mm = 10;
p = 0.5;

degrees_per_step = 1.8;
microstepping = 16;

r_step = 0;
theta = 0;
datapoints = [0; 0; 0];

disp("Connecting to Arduino...");
GPIO = arduino("/dev/ttyACM0", "Uno");
configurePin(GPIO, "D7", "DigitalOutput");
configurePin(GPIO, "D8", "DigitalOutput");
writeDigitalPin(GPIO, "D7", 0);
writeDigitalPin(GPIO, "D8", 0);
disp("Arduino configured.");

tcpip = tcpclient('192.168.0.20', 5555);
writeline(tcpip, "*IDN?");
readline(tcpip)

current_radius = min_distance_mm + centre_distance_offset_mm;
while current_radius <= max_distance_mm + centre_distance_offset_mm;

    writeline(tcpip, ':RUN');

    fprintf("Next radius step is %d mm\n", (current_radius - centre_distance_offset_mm));
    beep;
    proceed = input("Please position target, set oscilloscope channel sensitivity appropriately and hit enter.");

    current_arc_length_step_mm = arc_length_step_min_mm + (r_step * 2 * pi * p);

    if current_radius < (max_width_mm / 2)
        current_angle_rad = pi;
    else
        current_angle_rad = 2 * asin((max_width_mm / 2) / current_radius);
    end
    arc_length_mm = 2 * pi * current_radius * (current_angle_rad / (2 * pi));
    num_half_arc_points = floor((arc_length_mm / 2) / current_arc_length_step_mm);
    steps_per_point = round((current_arc_length_step_mm / current_radius) / deg2rad(degrees_per_step / microstepping));
    quantised_angle_step_rad = steps_per_point * deg2rad(degrees_per_step / microstepping);

    % Rotate all the way to the left
    rotate(GPIO, -1, steps_per_point * num_half_arc_points);
    pause(1);

    theta = -(num_half_arc_points * quantised_angle_step_rad);

    % Scan the left half points
    for i = 1:num_half_arc_points
        value = get_sample(tcpip)
        datapoints = [datapoints, [theta; current_radius; value]];
        rotate(GPIO, 1, steps_per_point);
        theta = theta + quantised_angle_step_rad;
    end

    value = get_sample(tcpip)
    datapoints = [datapoints, [theta; current_radius; value]];

    % Scan the right half points
    for i = 1:num_half_arc_points
        % Measure avg sig strength
        % Append to datapoints with polar coordinate details
        rotate(GPIO, 1, steps_per_point);
        theta = theta + quantised_angle_step_rad;
        value = get_sample(tcpip)
        datapoints = [datapoints, [theta; current_radius; value]];
    end

    % Move back to the centre
    rotate(GPIO, -1, steps_per_point * num_half_arc_points);

    r_step = r_step + 1;
    current_radius = current_radius + radius_step_mm;
end

function rotate(Arduino, direction, steps)
    if direction == -1
        writeDigitalPin(Arduino, "D8", 0);
    elseif direction == 1
        writeDigitalPin(Arduino, "D8", 1);
    else
        return
    end

    while steps
        writeDigitalPin(Arduino, "D7", 1);
        writeDigitalPin(Arduino, "D7", 0);
        steps = steps - 1;
    end
end

function result = get_sample(scope)
    writeline(scope, ':RUN');
    writeline(scope, ':SINGle');

    writeline(scope, ':TRIG:STAT?');
    trigger_status = readline(scope);
    while ~strcmp(trigger_status, "STOP")
        writeline(scope, ':TRIG:STAT?');
        trigger_status = readline(scope);
    end

    writeline(scope, ':WAV:MODE RAW');
    writeline(scope, ':WAV:STOP 12000');

    writeline(scope, ':WAV:SOURce CHAN1');
    writeline(scope, ":WAV:DATA?");
    string = readline(scope);
    string = convertStringsToChars(string);
    ascii_data = string(12:end);

    writeline(scope, ":WAV:YINC?");
    y_increment = str2double(readline(scope));

    output_waveform_data = zeros(length(ascii_data), 1);

    for i = 1:length(ascii_data)
        output_waveform_data(i) = uint8(ascii_data(i));
    end

    output_waveform_data = output_waveform_data - 128;
    output_waveform_data = output_waveform_data * y_increment;
    output_waveform_data = abs(output_waveform_data);
    result = mean(output_waveform_data);

    %timebase = 1:length(output_waveform_data);
    %plot(timebase, output_waveform_data);
end

    