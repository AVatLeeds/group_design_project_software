classdef optical_scan < handle
    properties
        sample_matrix = zeros(0, 0);
        sampler;
        h_max;
        v_max;
        current_coord = [1, 1];
    end

    methods
        function obj = optical_scan(width_mm, height_mm, step_mm, sampler_port)
            obj.sample_matrix = zeros((width_mm / step_mm) + 1, (height_mm / step_mm) + 1);
            obj.h_max = (width_mm / step_mm) + 1;
            obj.v_max = (height_mm / step_mm) + 1;
            disp("Connecting to Scope...");
            obj.sampler = tcpclient(sampler_port, 5555);
            writeline(obj.sampler, "*IDN?");
            readline(obj.sampler)
            disp("Scope connected.");
        end

        function h_step(obj, direction)
            if (direction == 1) && (obj.current_coord(1) < obj.h_max)
                obj.current_coord(1) = obj.current_coord(1) + 1;
            elseif (direction == -1) && (obj.current_coord(1) > 1)
                obj.current_coord(1) = obj.current_coord(1) - 1;
            else
                error("Error: Step out of bounds.");
            end
        end

        function v_step(obj, direction)
            if (direction == 1) && (obj.current_coord(2) < obj.v_max)
                obj.current_coord(2) = obj.current_coord(2) + 1;
            elseif (direction == -1) && (obj.current_coord(2) > 1)
                obj.current_coord(2) = obj.current_coord(2) - 1;
            else
                error("Error: Step out of bounds.");
            end
        end

        function light_sample(obj)
            obj.sample_matrix(obj.current_coord(1), obj.current_coord(2)) = get_waveform_magnitue(obj.sampler);
        end

        function light_sample_averaged(obj, num_averages)
            obj.sample_matrix(obj.current_coord(1), obj.current_coord(2)) = get_waveform_magnitue(obj.sampler);
            for i = 1:(num_averages - 1)
                obj.sample_matrix(obj.current_coord(1), obj.current_coord(2)) = (obj.sample_matrix(obj.current_coord(1), obj.current_coord(2)) + readVoltage(obj.sampler, "A0")) / 2;
            end
        end

        function X = get_sample_matrix(obj)
            X = obj.sample_matrix;
        end
    end
end

function result = get_waveform_magnitue(sampler)
    writeline(sampler, ':RUN');
    writeline(sampler, ':SINGle');

    writeline(sampler, ':TRIG:STAT?');
    trigger_status = readline(sampler);
    while ~strcmp(trigger_status, "STOP")
        writeline(sampler, ':TRIG:STAT?');
        trigger_status = readline(sampler);
    end

    writeline(sampler, ':WAV:MODE RAW');
    writeline(sampler, ':WAV:STOP 30000');

    writeline(sampler, ':WAV:SOURce CHAN1');
    writeline(sampler, ":WAV:DATA?");
    string = readline(sampler);
    string = convertStringsToChars(string);
    ascii_data = string(12:end);

    writeline(sampler, ":WAV:XINC?");
    x_increment = str2double(readline(sampler));
    writeline(sampler, ":WAV:YINC?");
    y_increment = str2double(readline(sampler));

    output_waveform_data = zeros(length(ascii_data), 1);

    for i = 1:length(ascii_data)
        output_waveform_data(i) = uint8(ascii_data(i));
    end

    output_waveform_data = output_waveform_data - 128;
    output_waveform_data = output_waveform_data * y_increment;

    output_waveform_data = abs(output_waveform_data);
    result = mean(output_waveform_data;);
end