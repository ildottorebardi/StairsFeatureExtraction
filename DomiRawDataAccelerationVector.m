clearvars -except iUpAcc iUpTime iDownAcc iDownTime iFlatAcc iFlatTime

% Setting the filenames
dataFiles = {'iFlat.csv'};

% accelGraph = figure;

for i = 1:numel(dataFiles)
        filename = char(dataFiles(i));
        file=filename(1:3);
    
    % Opening the CSV file
    openFile = csvread(filename(1,:));
    
    % Finding a value for initial time based on the phone's internal clock
    format long g;
    initialValue = csvread(filename,0,0,[0,0,0,0]);

    % Reading the 1st (time) column within the CSV file
    rows = size(openFile,1);
    timeColumn = openFile(:,1);

    % Creating a new column for adjusted time
    adjustedColumn = (timeColumn - initialValue)*1000;

    % Writing the new adjusted time column to the RHS of the original CSV file if there are only 4 existing columns within the file
    % Would prefer to use csvwrite for consistency but function can only write to 5 degrees of accuracy
%     columns = size(openFile, 2);
%     if columns == 4
%         dlmwrite(filename,[openFile,adjustedColumn], 'precision',14);
%     else
%     end
    
    % Creating new matrices of individual columns for X, Y and Z vertices and time, from the acceleration matrix
    accelX = abs(openFile(:,[2])*9.81);
    accelY = abs(openFile(:,[3])*9.81);
    accelZ = abs(openFile(:,[4])*9.81);
    iFlatTime = adjustedColumn;
    iFlatAcc = ((accelX.^2) + (accelY.^2) + (accelZ.^2)).^0.5;
    
    % Plotting a graph of the total acceleration vector in ms^-2 against time in milliseconds,
    % then saving the graph with the original .csv filename with "Acceleration Vector Graph" on the end
%     plot(accelTime, accelTotal);
%     hold on
%     title('Acceleration vs Time for Total Acceleration Vector');
%     xlabel('Time (ms)');
%     ylabel('Acceleration (ms^-2)');
end

% print(accelGraph, '-depsc', [file, ' iAccelerometer Vector Graph']);