% Control.m
%------------------------------------------------%
% By: Adam Hastings
% Date: 6th February 2023
% Module: ELEC3885 - Group Design Project
% Description:
%------------------------------------------------%
% A program which generates a GUI in order to
% control the positioning system, which then 
% outputs graphs showing the results of the scan
%------------------------------------------------%

setspeed = 0;   %Speed for scanner
x_coord = 0;    %X-coordinate boundary for scanner
y_coord = 0;    %Y-coordinate boundary for scanner

close all force %Close all windows
clear;
Controls()

function Controls()
% Main function

    % ------- Create Figure Window ------- %
    figure = uifigure;
    set(figure, 'Position', get(0, 'Screensize')); %Fullscreen
    figure.Name = "XY Positioning Control Software";

    % ------- Manage App Layout ------- %
    grid = uigridlayout(figure,[10 10]);
    grid.RowHeight = {50, 50, 50, 50, 200, 50, 50, 50, 50};
    grid.ColumnWidth = {150, 150, 150, 150, 100, 100, 100, 100, 100};

    % ------- Create UI components ------- %
    title = uilabel(grid);                  % Program title
    port_setup = uilabel(grid);             % Serial port setup instructions
    dimensions = uilabel(grid);             % Scan dimension instructions  
    step_size = uilabel(grid);              % Step size instructions
    dwell_time= uilabel(grid);              % Dwell time instructions
    averages = uilabel(grid);               % Averages instructions

    scanstatus = uilamp(grid);              % Scan status lamp

    baud_rate_dd = uidropdown(grid);           % Drop-down for setting baud rate.
    port_box = uieditfield(grid, 'text');       % Text entry box for serial port name

    dwell_time_knob = uiknob(grid,'discrete');        %Discrete Speed Control Knob
    begin = uibutton(grid,'ButtonPushedFcn',@beginPressed);    %Begin Button
    ending = uibutton(grid, 'ButtonPushedFcn',@endingPressed); %End Button
    x_coord_box = uieditfield(grid,'numeric');   %X-coordinate numeric input box 
    y_coord_box = uieditfield(grid,'numeric');   %Y-coordinate numeric input box
    step_box = uieditfield(grid, 'numeric');
    averages_box = uieditfield(grid, 'numeric');
    graph = uiaxes(grid);

    % ------- Lay out UI components ------- %

    title.Layout.Row = 1;
    title.Layout.Column = [3 8];

    port_setup.Layout.Row = 2;
    port_setup.Layout.Column = [1 2];

    dimensions.Layout.Row = 3;
    dimensions.Layout.Column = [1 2];

    step_size.Layout.Row = 4;
    step_size.Layout.Column = [1 2];

    dwell_time.Layout.Row = 5;
    dwell_time.Layout.Column = [1 2];

    averages.Layout.Row = 6;
    averages.Layout.Column = [1 2];

    port_box.Layout.Row = 2;
    port_box.Layout.Column = 3;

    baud_rate_dd.Layout.Row = 2;
    baud_rate_dd.Layout.Column = 4;

    x_coord_box.Layout.Row = 3;
    x_coord_box.Layout.Column = 3;

    y_coord_box.Layout.Row = 3;
    y_coord_box.Layout.Column = 4;

    step_box.Layout.Row = 4;
    step_box.Layout.Column = 3;

    dwell_time_knob.Layout.Row = 5;
    dwell_time_knob.Layout.Column = [3 4];

    averages_box.Layout.Row = 6;
    averages_box.Layout.Column = 3;

    begin.Layout.Row = 8;
    begin.Layout.Column = [1 2];

    ending.Layout.Row = 8;
    ending.Layout.Column = [3 4];

    x_coord_box.Layout.Row = 3;
    x_coord_box.Layout.Column = 3;

    y_coord_box.Layout.Row = 3;
    y_coord_box.Layout.Column = 4;

    graph.Layout.Row = [2 9];
    graph.Layout.Column = [6 10];


    % ------- Configure UI component appearance ------- %
    % Title attributes
    title.Text = "<b> XY Positioning Control Software </b>";
    title.Interpreter = "html";
    title.FontSize = 20;

    port_setup.Text = "1) Set port name and baud rate.";
    port_setup.FontSize = 14;

    dimensions.Text = "2) Set port dimensions X (mm) and Y (mm).";
    dimensions.FontSize = 14;

    step_size.Text = "3) Set step size (mm).";
    step_size.FontSize = 14;

    dwell_time.Text = "4) Set dwell time (s).";
    dwell_time.FontSize = 14;

    averages.Text = "5) Set number of averages.";
    averages.FontSize = 14;

    % Set Lamp Colour
    scanstatus.Color = [1 0 0];

    baud_rate_dd.Items = {'110', '300', '600', '1200', '2400', '4800', '9600', '14400', '19200', '38400', '57600', '115200', '128000', '256000'};
    baud_rate_dd.Value = '115200';

    dwell_time_knob.Items = {'0.4', '0.6', '0.8', '1.0', '1.2', '1.4', '1.6', '1.8', '2.0'};
    dwell_time_knob.Value = '1.0';

    x_coord_box.Value = 100;                 %Default value              
    x_coord_box.Limits = [0 740];            %Set lower and upper bound
    x_coord_box.RoundFractionalValues = 1;   %Round decimals

    y_coord_box.Value = 100;                 %Default value
    y_coord_box.Limits = [0 740];            %Set lower and upper bound
    y_coord_box.RoundFractionalValues = 1;   %Round decimals

    step_box.Value = 10;
    step_box.Limits = [1 740];
    step_box.RoundFractionalValues = 1;

    averages_box.Value = 0;
    averages_box.Limits = [0 100];

    % Set begin button attributes
    begin.Text = 'Begin';               %Text
    begin.FontColor = [0 0 0];          %Black font
    begin.BackgroundColor = [0 1 0];    %Green backround
    % Set end button attributes
    ending.Text = 'End';                %Text
    ending.FontColor = [0 0 0];         %Black font
    ending.BackgroundColor = [1 0 0];   %Red background
    % Tabulate different scan types
    scantypes.Items = ["Choose scan type" "Default Scan" "Sweep Scan" "Targetted Scan"];
    scantypes.Value = "Choose scan type";   %Default value 
    
    % ------- Button Functionality ------- %
    %Functionality for pressing the begin button
    function beginPressed(src,event)
        port = serialport(port_box.Value, str2double(baud_rate_dd.Value));
        writeline(port, "G28");
        writeline(port, "G91");

        dwell = str2double(dwell_time_knob.Value);
        x_coord = x_coord_box.Value;
        y_coord = y_coord_box.Value;
        step = step_box.Value; 

        scanstatus.Color = [0 1 0];
        sweepScan(dwell,x_coord,y_coord,step, port);
    end
    
    %Functionality for pressing the end button
    function endingPressed(src,event)
        scanstatus.Color = [1 0 0];
        writeline(port, "M0");
        pause(2);
        writeline(port,"G28");
        
    end
end

function sweepScan(dwell,xbound,ybound,step_size, port)
    import optical_scan.*;
    scan = optical_scan(xbound, ybound, step_size, "/dev/ttyACM1"); 
    direction = 1;
    for i = 1:(ybound / step_size)
        pause(dwell / 2);
        light_sample(scan);
        pause(dwell / 2);
      for j = 1:(xbound / step_size)
            string = "G0 X" + (step_size * direction) + "F10000";
            writeline(port, string);
            h_step(scan, direction);
            pause(dwell / 2);
            light_sample(scan);
            pause(dwell / 2);
      end
      string = "G0 Y" + (step_size)  + "F10000";
      writeline(port, string);
      direction = direction * -1;
      v_step(scan, 1);
    end
    optical_matrix = get_sample_matrix(scan);
    image(optical_matrix .* 250);
    colormap('gray');
end

%function targettedScan(xbound,ybound)
%    xstring = "G0 X" + (xbound*10);
%    writeline(port, xstring);
%    ystring = "G0 Y" + (ybound*10);
%    writeline(port, ystring);
%end

%function defaultScan(speed,xbound,ybound)
%    %Insert Default Scan Code Here
%end
