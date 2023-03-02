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
            disp("Connecting to Arduino...");
            obj.sampler = arduino(sampler_port, "Uno");
            configurePin(obj.sampler, "A0", "AnalogInput");
            disp("Arduino configured.");
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
            obj.sample_matrix(obj.current_coord(1), obj.current_coord(2)) = readVoltage(obj.sampler, "A0");
        end

        function light_sample_averaged(obj, num_averages)
            obj.sample_matrix(obj.current_coord(1), obj.current_coord(2)) = readVoltage(obj.sampler, "A0");
            for i = 1:(num_averages - 1)
                obj.sample_matrix(obj.current_coord(1), obj.current_coord(2)) = (obj.sample_matrix(obj.current_coord(0), obj.current_coord(1)) + readVoltage(obj.sampler, "A0")) / 2;
            end
        end

        function X = get_sample_matrix(obj)
            X = obj.sample_matrix;
        end
    end
end