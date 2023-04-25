% Control.m
%------------------------------------------------%
% By: Adam Hastings
% Date: 6th February 2023
% Module: ELEC3885 - Group Design Project
% Description:
%------------------------------------------------%
% A program which generates a GUI in order tode
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
    fig = uifigure;
    set(fig, 'Position', get(0, 'Screensize')); %Fullscreen
    fig.Name = "XY Positioning Control Software";

    % ------- Manage App Layout ------- %
    grid = uigridlayout(fig,[10 10]);
    grid.RowHeight = {50, 50, 50, 50, 50, 200, 50, 50, 50, 50, 50, 50,'1x'};
    grid.ColumnWidth = {150, 150, 150, 150, 100, 100, 100, 100, 100,'1x'};

    % ------- Create UI components ------- %
    ptitle = uilabel(grid);                  % Program title
    scanner_port_setup = uilabel(grid);             % Scanner serial port setup instructions
    sampler_port_setup = uilabel(grid);             % Scanner serial port setup instructions
    dimensions = uilabel(grid);             % Scan dimension instructions  
    step_size = uilabel(grid);              % Step size instructions
    dwell_time= uilabel(grid);              % Dwell time instructions
    averages = uilabel(grid);               % Averages instructions
    scan_lamp = uilabel(grid);              % Scan Status Lamp
    scan = uilabel(grid);                   % Scan type drow-down
    scale_factor = uilabel(grid);

    scanstatus = uilamp(grid);              % Scan status lamp

    scanner_baud_rate_dd = uidropdown(grid);           % Drop-down for setting scanner baud rate.
    scanner_port_box = uieditfield(grid, 'text');       % Text entry box for scanner serial port name
    sampler_port_box = uieditfield(grid, 'text');       % Text entry box for sampler serial port name
    scantypes = uidropdown(grid);
    dwell_time_knob = uiknob(grid,'discrete');        %Discrete Speed Control Knob
    begin = uibutton(grid,'ButtonPushedFcn',@beginPressed);    %Begin Button
    ending = uibutton(grid, 'ButtonPushedFcn',@endingPressed); %End Button
    x_coord_box = uieditfield(grid,'numeric');   %X-coordinate numeric input box 
    y_coord_box = uieditfield(grid,'numeric');   %Y-coordinate numeric input box
    step_box = uieditfield(grid, 'numeric');
    averages_box = uieditfield(grid, 'numeric');
    scale_factor_box = uieditfield(grid, 'numeric');

    graph = uiaxes(grid);
    graph.Layout.Row = [1 10];
    graph.Layout.Column = [6 10];
    
    % ------- Lay out UI components ------- %

    ptitle.Layout.Row = 1;
    ptitle.Layout.Column = [3 8];

    scanner_port_setup.Layout.Row = 2;
    scanner_port_setup.Layout.Column = [1 2];

    sampler_port_setup.Layout.Row = 3;
    sampler_port_setup.Layout.Column = [1 2];

    dimensions.Layout.Row = 4;
    dimensions.Layout.Column = [1 2];

    step_size.Layout.Row = 5;
    step_size.Layout.Column = [1 2];

    dwell_time.Layout.Row = 6;
    dwell_time.Layout.Column = [1 2];

    averages.Layout.Row = 7;
    averages.Layout.Column = [1 2];

    scan_lamp.Layout.Row = 12;
    scan_lamp.Layout.Column = 1;

    scanstatus.Layout.Row = 12;
    scanstatus.Layout.Column = 2;

    scanner_port_box.Layout.Row = 2;
    scanner_port_box.Layout.Column = 3;

    scanner_baud_rate_dd.Layout.Row = 2;
    scanner_baud_rate_dd.Layout.Column = 4;

    sampler_port_box.Layout.Row = 3;
    sampler_port_box.Layout.Column = 3;

    x_coord_box.Layout.Row = 4;
    x_coord_box.Layout.Column = 3;

    y_coord_box.Layout.Row = 4;
    y_coord_box.Layout.Column = 4;

    step_box.Layout.Row = 5;
    step_box.Layout.Column = 3;

    dwell_time_knob.Layout.Row = 6;
    dwell_time_knob.Layout.Column = [3 4];

    averages_box.Layout.Row = 7;
    averages_box.Layout.Column = 3;

    begin.Layout.Row = 11;
    begin.Layout.Column = [1 2];

    ending.Layout.Row = 11;
    ending.Layout.Column = [3 4];

    x_coord_box.Layout.Row = 4;
    x_coord_box.Layout.Column = 3;

    y_coord_box.Layout.Row = 4;
    y_coord_box.Layout.Column = 4;

    scan.Layout.Row = 9;
    scan.Layout.Column = 1;

    scantypes.Layout.Row = 9;
    scantypes.Layout.Column = 3;

    scale_factor.Layout.Row = 10;
    scale_factor.Layout.Column = [1 2];

    scale_factor_box.Layout.Row = 10;
    scale_factor_box.Layout.Column = 3;

    % ------- Configure UI component appearance ------- %
    % Title attributes
    ptitle.Text = "<b> XY Positioning Control Software </b>";
    ptitle.Interpreter = "html";
    ptitle.FontSize = 20;

    scanner_port_setup.Text = "1) Set scanner port name and baud rate.";
    scanner_port_setup.FontSize = 14;

    sampler_port_setup.Text = "2) Set sampler port name";
    sampler_port_setup.FontSize = 14;

    dimensions.Text = "3) Set scan dimensions X (mm) and Y (mm).";
    dimensions.FontSize = 14;

    step_size.Text = "4) Set step size (mm).";
    step_size.FontSize = 14;

    dwell_time.Text = "5) Set dwell time (s).";
    dwell_time.FontSize = 14;

    averages.Text = "6) Set number of averages (0 for no averaging).";
    averages.FontSize = 14;

    scan.Text = "7) Set Scan Type.";
    scan.FontSize = 14;

    scale_factor.Text = "8) Scaling factor for output data.";
    scale_factor.FontSize = 14;

    scan_lamp.Text = "Scan Status:";
    scan_lamp.FontSize = 14;
   
    % Set Lamp Colour
    scanstatus.Color = [1 0 0];

    scanner_baud_rate_dd.Items = {'110', '300', '600', '1200', '2400', '4800', '9600', '14400', '19200', '38400', '57600', '115200', '128000', '256000'};
    scanner_baud_rate_dd.Value = '115200';

    dwell_time_knob.Items = {'0.0', '0.1', '0.2', '0.4', '0.6', '0.8', '1.0', '1.2', '1.4', '1.6', '1.8', '2.0'};
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

    scantypes.Items = ["Radar Scan" "Optical Scan" "Targetted Scan"];
    scantypes.Value = "Optical Scan";   %Default value

    scale_factor_box.Value = 10;
    scale_factor_box.Limits = [1 60];

    averages_box.Value = 0;
    averages_box.Limits = [0 10];

    % Set begin button attributes
    begin.Text = 'Begin';               %Text
    begin.FontColor = [0 0 0];          %Black font
    begin.BackgroundColor = [0 1 0];    %Green backround
    % Set end button attributes
    ending.Text = 'End';                %Text
    ending.FontColor = [0 0 0];         %Black font
    ending.BackgroundColor = [1 0 0];   %Red background
    
    % ------- Button Functionality ------- %
    %Functionality for pressing the begin button
    function beginPressed(src,event)
        ardfig = uifigure;
        uialert(ardfig,'Connecting to Arduino...','Alert', 'Icon','info');
        ardfig.WindowStyle = 'modal';
        sampler_port = sampler_port_box.Value;
        port = serialport(scanner_port_box.Value, str2double(scanner_baud_rate_dd.Value));
        writeline(port, "G28");
        while (readline(port) ~= "ok") 
        end
        writeline(port, "G91");
        while (readline(port) ~= "ok") 
        end
        writeline(port, "G0 Z3");
        while (readline(port) ~= "ok") 
        end
        writeline(port, "M400");
        while (readline(port) ~= "ok") 
        end
        dwell = str2double(dwell_time_knob.Value);
        averages = uint32(averages_box.Value);
        x_coord = x_coord_box.Value;
        y_coord = y_coord_box.Value;
        step = step_box.Value; 
        scantype = scantypes.Value;
        switch scantype
            case "Radar Scan"
                scanstatus.Color = [0 1 0];
                defaultScan(dwell,x_coord,y_coord,step, port, ardfig, sampler_port, averages, scale_factor_box.Value);
            case "Optical Scan"
                scanstatus.Color = [0 1 0];
                sweepScan(dwell,x_coord,y_coord,step, port, ardfig, sampler_port, averages, scale_factor_box.Value);                
            case "Targetted Scan" 
                scanstatus.Color = [0 1 0];
                targettedScan(x_coord,y_coord,port)   
        end      
    end
    
    %Functionality for pressing the end button
    function endingPressed(src,event)
        scanstatus.Color = [1 0 0];
        writeline(port, "M0");
        while (readline(port) ~= "ok") 
        end
        flush(port);
        close all force
        clear
    end

    function seeResults(matrix)
        hold on
        subplot(1,2,1)
        a = size(matrix);
        J = filter2(fspecial('sobel'),matrix(1:a(1),1:a(2)));
        imshow(matrix / 5);
        title('Optical Image:')
        subplot(1,2,2)
        K = mat2gray(J);
        imshow(K)
        title('Reconstructed Image:')
    end
    
    function sweepScan(dwell,xbound,ybound,step_size, port, ardfig, sampler_port, averages, scale_factor)
    % --------- Optical Scan ----------%
    import optical_scan.*;
    scan = optical_scan(xbound, ybound, step_size, sampler_port); 
    close(ardfig)
    progbarfig = uifigure;
    progbarfig.Position = [500 500 420 180];
    prog = uiprogressdlg(progbarfig,'Message','Scan Starting!','Title','Scan Progress Bar','Icon','info');
    prog.ShowPercentage = 1;
    prog.Value = 0;
    prog.Cancelable = 1;
    prog.CancelText = 'Cancel Scan';
    pause(dwell);
    prog.Message = 'Scan in progress...';
    increment = (xbound/step_size) * ((ybound/step_size) + 1);
    direction = 1;
    total = 0;
    for i = 1:(ybound / step_size)
        pause(dwell / 2);
        if averages == 0
            light_sample(scan);
        else 
            light_sample_averaged(scan, averages);
        end
        pause(dwell / 2);
      for j = 1:(xbound / step_size)
            string = "G0 X" + (step_size * direction) + "F10000";
            writeline(port, string);
            flush(port); 
            writeline(port, "M400");
            while (readline(port) ~= "ok") 
            end
            h_step(scan, direction);
            pause(dwell / 2);
            if averages == 0
                light_sample(scan);
            else 
                light_sample_averaged(scan, averages);
            end
            pause(dwell / 2);
            total = total + 1;
            prog.Value = (total)/increment;
            pause(dwell)
            if prog.CancelRequested == 1
                writeline(port,'M0');
                while (readline(port) ~= "ok") 
                end
                break
            end
      end
      if prog.CancelRequested == 1
          break
      end
      string = "G0 Y" + (step_size)  + "F10000";
      writeline(port, string);
      flush(port); 
      writeline(port, "M400");
      while (readline(port) ~= "ok") 
      end
      direction = direction * -1;
      v_step(scan, 1);
    end
    pause(dwell / 2);
    if averages == 0
        light_sample(scan);
    else 
        light_sample_averaged(scan, averages);
    end
    pause(dwell / 2);
    for j = 1:(xbound / step_size)
        string = "G0 X" + (step_size * direction) + "F10000";
        writeline(port, string);
        flush(port); 
        writeline(port, "M400");
        while (readline(port) ~= "ok") 
        end
        h_step(scan, direction);
        pause(dwell / 2);
        if averages == 0
            light_sample(scan);
        else 
            light_sample_averaged(scan, averages);
        end
        pause(dwell / 2);
        total = total + 1;
        prog.Value = (total)/increment;
        pause(dwell)
        if prog.CancelRequested == 1
            writeline(port,'M0');
            while (readline(port) ~= "ok") 
            end
            break
        end
    end
    optical_matrix = get_sample_matrix(scan);
    minimum = min(optical_matrix);
    optical_matrix = optical_matrix - minimum;
    optical_matrix = optical_matrix .* scale_factor;
    seeResults(optical_matrix)   
    end

function targettedScan(xbound,ybound,port)
    string = "G0 X" + (xbound) + "G0 Y" + (ybound) + "F10000";
    writeline(port, string); 
    flush(port); 
    writeline(port, "M400");
    while (readline(port) ~= "ok") 
    end
end

function defaultScan(dwell,xbound,ybound,step_size, port, ardfig, sampler_port, averages, scale_factor)
    import optical_scan.*;
    scan = optical_scan(xbound, ybound, step_size, sampler_port); 
    close(ardfig)
    progbarfig = uifigure;
    progbarfig.Position = [500 500 420 180];
    prog = uiprogressdlg(progbarfig,'Message','Scan Starting!','Title','Scan Progress Bar','Icon','info');
    prog.ShowPercentage = 1;
    prog.Value = 0;
    prog.Cancelable = 1;
    prog.CancelText = 'Cancel Scan';
    pause(dwell);
    prog.Message = 'Scan in progress...';
    increment = (xbound/step_size) * ((ybound/step_size) + 1);
    direction = 1;
    total = 0;
    for i = 1:(ybound / step_size)
        pause(dwell / 2);
        if averages == 0
            light_sample(scan);
        else 
            light_sample_averaged(scan, averages);
        end
        pause(dwell / 2);
      for j = 1:(xbound / step_size)
            string = "G0 X" + (step_size * direction) + "F10000";
            writeline(port, string);
            flush(port); 
            writeline(port, "M400");
            while (readline(port) ~= "ok") 
            end
            h_step(scan, direction);
            pause(dwell / 2);
            if averages == 0
                light_sample(scan);
            else 
                light_sample_averaged(scan, averages);
            end
            pause(dwell / 2);
            total = total + 1;
            prog.Value = (total)/increment;
            pause(dwell)
            if prog.CancelRequested == 1
                writeline(port,'M0');
                while (readline(port) ~= "ok") 
                end
                break
            end
      end
      if prog.CancelRequested == 1
          break
      end
      string = "G0 Y" + (step_size)  + "F10000";
      writeline(port, string);
      flush(port); 
      writeline(port, "M400");
      while (readline(port) ~= "ok") 
      end
      direction = direction * -1;
      v_step(scan, 1);
    end
    pause(dwell / 2);
    if averages == 0
        light_sample(scan);
    else 
        light_sample_averaged(scan, averages);
    end
    pause(dwell / 2);
    for j = 1:(xbound / step_size)
        string = "G0 X" + (step_size * direction) + "F10000";
        writeline(port, string);
        flush(port); 
        writeline(port, "M400");
        while (readline(port) ~= "ok") 
        end
        h_step(scan, direction);
        pause(dwell / 2);
        if averages == 0
            light_sample(scan);
        else 
            light_sample_averaged(scan, averages);
        end
        pause(dwell / 2);
        total = total + 1;
        prog.Value = (total)/increment;
        pause(dwell)
        if prog.CancelRequested == 1
            writeline(port,'M0');
            while (readline(port) ~= "ok") 
            end
            break
        end
    end
    optical_matrix = get_sample_matrix(scan);
    minimum = min(optical_matrix);
    optical_matrix = optical_matrix - minimum;
    optical_matrix = optical_matrix .* scale_factor;
    seeResults(optical_matrix)   
    end
end
