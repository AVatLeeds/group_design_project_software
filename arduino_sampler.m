clear;

%PORT_NAME = "/dev/ttyACM0";
%sampler = arduino(PORT_NAME, "Uno");
%configurePin(sampler, "A0", "AnalogInput");
%sample = readVoltage(sampler, "A0");

optical_scan = optical_scan(10, 10, 1, "/dev/ttyACM0");

for i = 1:10
    light_sample(optical_scan);
    for j = 1:10
        if mod(i, 2) == 1
            h_step(optical_scan, 1);
        else
            h_step(optical_scan, -1);
        end
        light_sample(optical_scan);
    end
    v_step(optical_scan, 1);
end
light_sample(optical_scan);
for j = 1:10
    h_step(optical_scan, 1);
    light_sample(optical_scan);
end

results = get_sample_matrix(optical_scan);