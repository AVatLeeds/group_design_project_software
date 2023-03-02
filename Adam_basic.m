% Basic.m
%------------------------------------------------%
% By: Adam Hastings
% Date: 3rd February 2023
% Module: ELEC3885 - Group Design Project
% Description:
%------------------------------------------------%
% A program which simply attempts to communicate
% with the duet board without using a GUI
%------------------------------------------------%

%Initialising the port
port = serialport("COM3", 115200);
writeline(port, "G28");
writeline(port, "G91");
direction = 10;
for i = 0:100
      for j = 0:100
            string = "G0 X" + direction;
            writeline(port, string);
            pause(0.2);
      end
      writeline(port, "G0 Y10");
      direction = direction * -1;
      pause(0.2)
end


