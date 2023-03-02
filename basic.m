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
clear;
port = serialport("/dev/ttyACM0", 115200);
writeline(port, "G28");
writeline(port, "G91");
direction = 10;
for i = 0:7
      for j = 0:7
            string = "G0 X" + direction + "F10000";
            writeline(port, string);
            pause(0.5);
      end
      writeline(port, "G0 Y10 F10000");
      direction = direction * -1;
      pause(0.6)
end
writeline(port, "G28");


