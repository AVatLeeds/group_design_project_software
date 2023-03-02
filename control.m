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

%Initialising the port
port = serialport("/dev/ttyACM0", 115200);
writeline(port, "G28");
writeline(port, "G91");

setspeed = 0;   %Speed for scanner
x_coord = 0;    %X-coordinate boundary for scanner
y_coord = 0;    %Y-coordinate boundary for scanner

close all force %Close all windows
Controls(port)

function Controls(port)
% Main function

    % ------- Create Figure Window ------- %
    figure = uifigure;
    set(figure, 'Position', get(0, 'Screensize')); %Fullscreen
    figure.Name = "XY Positioning Control Software";

    % ------- Manage App Layout ------- %
    grid = uigridlayout(figure,[9 9]);
    grid.RowHeight = {70,30,150,30,50,150,130,50,50};
    grid.ColumnWidth = {200,200,50,50,100,'1x'};

    % ------- Create UI components ------- %
    title = uilabel(grid);                  %Program Title
    prompt1 = uilabel(grid);                %Scan Type Instruction        
    prompt2 = uilabel(grid);                %Speed Instruction
    prompt3 = uilabel(grid);                %Coordinates Instruction
    prompt4 = uilabel(grid);                %Targetted Scan Note
    prompt5 = uilabel(grid);                %Scan Status Text
    scanstatus = uilamp(figure);            %Scan Status Lamp
    scantypes = uidropdown(grid);           %Scan Type Drop-Down
    speed = uiknob(grid,'discrete');        %Discrete Speed Control Knob
    begin = uibutton(grid,'ButtonPushedFcn',@beginPressed);    %Begin Button
    ending = uibutton(grid, 'ButtonPushedFcn',@endingPressed); %End Button
    xcoord = uieditfield(grid,'numeric');   %X-coordinate numeric input box 
    ycoord = uieditfield(grid,'numeric');   %Y-coordinate numeric input box
    topgraph = uiaxes(grid);                %Top graph axes
    bottomgraph = uiaxes(grid);             %Bottom graph axes

    % ------- Lay out UI components ------- %
    % Position Title Label
    title.Layout.Row = 1;
    title.Layout.Column = [5 6];
    % Position prompt 1
    prompt1.Layout.Row = 2;
    prompt1.Layout.Column = [1 2];
    % Position prompt 2
    prompt2.Layout.Row = 3;
    prompt2.Layout.Column = [1 2];
    % Position prompt 3
    prompt3.Layout.Row = 4;
    prompt3.Layout.Column = [1 2];
    % Position prompt 4
    prompt4.Layout.Row = 5;
    prompt4.Layout.Column = [1 2];
    % Position prompt 5
    prompt5.Layout.Row = 9;
    prompt5.Layout.Column = 1;
    % Position scan status lamp 
    scanstatus.Position = [100 60 20 20];
    % Position speed knob
    speed.Layout.Row = 3;
    speed.Layout.Column = 2;
    % Position begin button
    begin.Layout.Row = 8;
    begin.Layout.Column = 1;
    % Position end button
    ending.Layout.Row = 8;
    ending.Layout.Column = 2;
    % Position drop-down
    scantypes.Layout.Row = 2;
    scantypes.Layout.Column = 2;
    % Position xcoord input
    xcoord.Layout.Row = 4;
    xcoord.Layout.Column = 3;
    % Position ycoord input
    ycoord.Layout.Row = 4;
    ycoord.Layout.Column = 4;
    % Position top graph
    topgraph.Layout.Row = [2 5];
    topgraph.Layout.Column = [5 9];
    % Position bottom graph
    bottomgraph.Layout.Row = [6 8];
    bottomgraph.Layout.Column = [5 9];

    % ------- Configure UI component appearance ------- %
    % Title attributes
    title.Text = "<b> XY Positioning Control Software </b>";
    title.Interpreter = "html";
    title.FontSize = 20;
    % Prompt 1 attributes
    prompt1.Text = "1) Select type of scan:";
    prompt1.FontSize = 14;
    % Prompt 2 attributes
    prompt2.Text = "2) Select speed of scan:";
    prompt2.FontSize = 14;
    % Prompt 3 attributes
    prompt3.Text = "3) Select the boundary of the scan (X,Y):";
    prompt3.FontSize = 14;
    % Prompt 4 attributes
    prompt4.Text = "(Note, if using a targetted scan, set the above to the target coordinates)";
    prompt4.FontSize = 10;
    % Prompt 5 attributes
    prompt5.Text = "Scan Status:";
    prompt5.FontSize = 14;
    % Set Lamp Colour
    scanstatus.Color = [1 0 0];
    % Set speed knob values and default setting
    speed.Items = {'0.25','0.5','1','1.5','2'};
    speed.Value = '1';
    % Set x-coord box attributes
    xcoord.Value = 100;                 %Default value              
    xcoord.Limits = [0 100];            %Set lower and upper bound
    xcoord.RoundFractionalValues = 1;   %Round decimals
    % Set y-coord box attributes
    ycoord.Value = 100;                 %Default value
    ycoord.Limits = [0 100];            %Set lower and upper bound
    ycoord.RoundFractionalValues = 1;   %Round decimals
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
    % Setup basic graphs 
    x = [0:1:10];
    y = x;
    z = x.^2;
    plot(topgraph,x,y);
    plot(bottomgraph,x,z);
    
    % ------- Button Functionality ------- %
    %Functionality for pressing the begin button
    function beginPressed(src,event)
        scantype = scantypes.Value;
        s = speed.Value;
        setspeed = str2double(s);
        x_coord = xcoord.Value;
        y_coord = ycoord.Value;
        switch scantype
            case "Choose scan type"
                alert = uifigure;
                uialert(alert,'Please choose a scan type','Invalid Selection');
            case "Default Scan"
                scanstatus.Color = [0 1 0];
                %defaultScan(a,a,a)
            case "Sweep Scan"     
                scanstatus.Color = [0 1 0];
                sweepScan(setspeed,x_coord,y_coord, port)                
            case "Targetted Scan" 
                scanstatus.Color = [0 1 0];
                targettedScan(x_coord,y_coord)
                
        end
    end
    
    %Functionality for pressing the end button
    function endingPressed(src,event)
        scanstatus.Color = [1 0 0];
        writeline(port, "M0");
        pause(2);
        writeline(port,"G28");
        
    end
end

function sweepScan(speed,xbound,ybound, port)
    direction = 1;
    for i = 0:ybound
      for j = 0:xbound
            string = "G0 X" + (direction*10) + "F10000";
            writeline(port, string);
            pause(0.2 / speed);
      end
      writeline(port, "G0 Y10 F10000");
      direction = direction * -1;
      pause(0.2 / speed)
    end
end

function targettedScan(xbound,ybound)
    xstring = "G0 X" + (xbound*10);
    writeline(port, xstring);
    ystring = "G0 Y" + (ybound*10);
    writeline(port, ystring);
end

function defaultScan(speed,xbound,ybound)
    %Insert Default Scan Code Here
end
