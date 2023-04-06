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
    fig = uifigure;
    set(fig, 'Position', get(0, 'Screensize')); %Fullscreen
    fig.Name = "XY Positioning Control Software";

    % ------- Manage App Layout ------- %
    grid = uigridlayout(fig,[10 10]);
    grid.RowHeight = {50, 50, 50, 50, 200, 50, 50, 50, 50, 20, 50, '1x'};
    grid.ColumnWidth = {150, 150, 150, 150, 100, 100, 100, 100, 100,'1x'};

    % ------- Create UI components ------- %
    ptitle = uilabel(grid);                  % Program title
    port_setup = uilabel(grid);             % Serial port setup instructions
    dimensions = uilabel(grid);             % Scan dimension instructions  
    step_size = uilabel(grid);              % Step size instructions
    dwell_time= uilabel(grid);              % Dwell time instructions
    averages = uilabel(grid);               % Averages instructions
    scan_lamp = uilabel(grid);              % Scan Status Lamp
    scan = uilabel(grid);                   % Scan type drow-down

    scanstatus = uilamp(grid);              % Scan status lamp

    baud_rate_dd = uidropdown(grid);           % Drop-down for setting baud rate.
    port_box = uieditfield(grid, 'text');       % Text entry box for serial port name
    scantypes = uidropdown(grid);
    dwell_time_knob = uiknob(grid,'discrete');        %Discrete Speed Control Knob
    begin = uibutton(grid,'ButtonPushedFcn',@beginPressed);    %Begin Button
    ending = uibutton(grid, 'ButtonPushedFcn',@endingPressed); %End Button
    x_coord_box = uieditfield(grid,'numeric');   %X-coordinate numeric input box 
    y_coord_box = uieditfield(grid,'numeric');   %Y-coordinate numeric input box
    step_box = uieditfield(grid, 'numeric');
    averages_box = uieditfield(grid, 'numeric');

    graph = uiaxes(grid);
    graph.Layout.Row = [1 10];
    graph.Layout.Column = [6 10];
    
    % ------- Lay out UI components ------- %

    ptitle.Layout.Row = 1;
    ptitle.Layout.Column = [3 8];

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

    scan_lamp.Layout.Row = 10;
    scan_lamp.Layout.Column = 1;

    scanstatus.Layout.Row = 10;
    scanstatus.Layout.Column = 2;

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

    begin.Layout.Row = 9;
    begin.Layout.Column = [1 2];

    ending.Layout.Row = 9;
    ending.Layout.Column = [3 4];

    x_coord_box.Layout.Row = 3;
    x_coord_box.Layout.Column = 3;

    y_coord_box.Layout.Row = 3;
    y_coord_box.Layout.Column = 4;

    scan.Layout.Row = 8;
    scan.Layout.Column = 1;

    scantypes.Layout.Row = 8;
    scantypes.Layout.Column = 3;

    % ------- Configure UI component appearance ------- %
    % Title attributes
    ptitle.Text = "<b> XY Positioning Control Software </b>";
    ptitle.Interpreter = "html";
    ptitle.FontSize = 20;

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

    scan.Text = "6) Set Scan Type.";
    scan.FontSize = 14;

    scan_lamp.Text = "Scan Status:";
    scan_lamp.FontSize = 14;
   
    % Set Lamp Colour
    scanstatus.Color = [1 0 0];

    baud_rate_dd.Items = {'110', '300', '600', '1200', '2400', '4800', '9600', '14400', '19200', '38400', '57600', '115200', '128000', '256000'};
    baud_rate_dd.Value = '115200';

    dwell_time_knob.Items = {'0.2', '0.4', '0.6', '0.8', '1.0', '1.2', '1.4', '1.6', '1.8', '2.0'};
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

    scantypes.Items = ["Default Scan" "Sweep Scan" "Targetted Scan"];
    scantypes.Value = "Sweep Scan";   %Default value

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
    
    % ------- Button Functionality ------- %
    %Functionality for pressing the begin button
    function beginPressed(src,event)
        ardfig = uifigure;
        uialert(ardfig,'Connecting to Arduino...','Alert', 'Icon','info');
        ardfig.WindowStyle = 'modal';
        port = serialport(port_box.Value, str2double(baud_rate_dd.Value));
        writeline(port, "G28");
        writeline(port, "G91");
        dwell = str2double(dwell_time_knob.Value);
        x_coord = x_coord_box.Value;
        y_coord = y_coord_box.Value;
        step = step_box.Value; 
        scantype = scantypes.Value;
        switch scantype
            case "Default Scan"
                %scanstatus.Color = [0 1 0];
                %defaultScan(a,a,a)
            case "Sweep Scan"
                %progressBar(x_coord,y_coord,step,dwell)
                scanstatus.Color = [0 1 0];
                sweepScan(dwell,x_coord,y_coord,step, port, ardfig);                
            case "Targetted Scan" 
                scanstatus.Color = [0 1 0];
                targettedScan(x_coord,y_coord,port)   
        end      
    end
    
    %Functionality for pressing the end button
    function endingPressed(src,event)
        scanstatus.Color = [1 0 0];
        writeline(port, "M0");
        pause(2);
        writeline(port, "M2");
        pause(2);
        writeline(port,"G28");        
    end

    function seeResults(matrix)
        hold on
        subplot(1,2,1)
        a = size(matrix);
        J = filter2(fspecial('sobel'),matrix(1:a(1),1:a(2)));
        imshow(J)
        title('Optical Image:')
        subplot(1,2,2)
        K = mat2gray(J);
        imshow(K)
        title('Reconstructed Image:')
    end
    
    function sweepScan(dwell,xbound,ybound,step_size, port, ardfig)
    % --------- Progress Bar ----------%
    
    % --------- Optical Scan ----------%
    import optical_scan.*;
    scan = optical_scan(xbound, ybound, step_size, "/dev/ttyACM1"); 
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
    increment = (xbound/step_size) * (ybound/step_size);
    direction = 1;
    total = 0;
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
            total = total + 1;
            prog.Value = (total)/increment;
            pause(dwell)
            if prog.CancelRequested == 1
                writeline(port,'M0');
                break
            end
      end
      if prog.CancelRequested == 1
          break
      end
      string = "G0 Y" + (step_size)  + "F10000";
      writeline(port, string);
      direction = direction * -1;
      v_step(scan, 1);
    end
    optical_matrix = get_sample_matrix(scan) .* 2.5;
    seeResults(optical_matrix)   
    end

end


    

function targettedScan(xbound,ybound,port)
    string = "G0 X" + (xbound) + "G0 Y" + (ybound) + "F10000";
    writeline(port, string);  
end

%function defaultScan(speed,xbound,ybound)
%    %Insert Default Scan Code Here
%end
