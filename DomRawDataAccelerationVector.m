clearvars -except UpAcc UpTime DownAcc DownTime FlatAcc FlatTime
% Setting the filenames
dataFiles = {'Flat.csv'};

% accelGraph = figure;

for i = 1:numel(dataFiles)
        filename = char(dataFiles(i));
        file=filename(1:3);
    
    % Opening the CSV file
    openFile = csvread(filename);
    
    % Finding a value for initial time based on the phone's internal clock
    format long g;
    initialValue = csvread(filename,0,3,[0,3,0,3]);
    % disp(initialValue);
    
    % Reading the 4th (time) column within the CSV file
    rows = size(openFile,1);
    timeColumn = csvread(filename,0,3,[0,3,rows-1,3]);
    % disp(timeColumn);
    
    % Creating a new column for adjusted time
    adjustedColumn = timeColumn - initialValue;
    % disp(adjustedColumn);
    
    % Writing the new adjusted time column to the RHS of the original CSV file if there are only 5 existing columns within the file
    % Would prefer to use csvwrite for consistency but function can only write to 5 degrees of accuracy
    columns = size(openFile, 2);
    if columns == 5
        dlmwrite(filename,[openFile,adjustedColumn], 'precision',12);
    else
    end
    
    % Parsing through the CSV file and creating individual matrices for accelerometer, magnetometer and gyroscope data
    accelValues = [];
    magValues = [];
    gyroValues = [];
    for i = 0:rows-1
        rowParse = csvread(filename,i,0,[i,0,i,7]);
        if rowParse(6) == 777777;
            accelValues = [accelValues; rowParse];
        elseif rowParse(5) == 888888;
            magValues = [magValues; rowParse];
        elseif rowParse(5) == 999999;
            gyroValues = [gyroValues; rowParse];
        else
        end
    end
    
    % Creating new matrices of individual columns for X, Y and Z vertices and time, from the acceleration matrix
    accelX = accelValues(:,[1]);
    accelY = accelValues(:,[2]);
    accelZ = accelValues(:,[3]);
    FlatTime = accelValues(:,[7]);
    FlatAcc = ((accelX.^2) + (accelY.^2) + (accelZ.^2)).^0.5;
    
    % Plotting a graph of the total acceleration vector in ms^-2 against time in milliseconds,
    % then saving the graph with the original .csv filename with "Acceleration Vector Graph" on the end
%     plot(accelTime2, accelTotal2);
%     hold on
%     title('Acceleration vs Time for Total Acceleration Vector');
%     xlabel('Time (ms)');
%     ylabel('Acceleration (ms^-^2)');
%     legend('Flat','Up');
end

% print(accelGraph, '-depsc', [file, ' Accelerometer Vector Graph']);