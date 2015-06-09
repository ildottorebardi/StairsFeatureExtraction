clear all;

% Setting the filename
filename = 'DomiFlat.csv';
disp(filename);
file=filename(1:end-4);

% Opening the CSV file
openFile = csvread(filename);

% Finding a value for initial time based on the phone's internal clock
format long g;
initialValue = csvread(filename,0,0,[0,0,0,0]);

% Reading the 1st (time) column within the CSV file
rows = size(openFile,1);
timeColumn = csvread(filename,0,0,[0,0,rows-1,0]);

% Creating a new column for adjusted time
adjustedColumn = (timeColumn - initialValue)*1000;

% Writing the new adjusted time column to the RHS of the original CSV file if there are only 4 existing columns within the file
% Would prefer to use csvwrite for consistency but function can only write to 5 degrees of accuracy
columns = size(openFile, 2);
if columns == 4
    dlmwrite(filename,[openFile,adjustedColumn], 'precision',14);
else
end

% Creating new matrices of individual columns for X, Y and Z vertices and time, from the original file
accelX = abs(openFile(:,[2])*9.81);
accelY = abs(openFile(:,[3])*9.81);
accelZ = abs(openFile(:,[4])*9.81);
accelTime = openFile(:,[5]);

% Plotting a graph of acceleration in ms^-2 against time in milliseconds for the three different vertices, 
% then saving the graph with the original .csv filename with "Accelerometer Graph" on the end
accelGraph = figure;
plot(accelTime, accelX);
hold on
plot(accelTime, accelY);
hold on
plot(accelTime, accelZ);
title('Acceleration vs Time for Acceleration in the X, Y & Z Vertices');
xlabel('Time (ms)');
ylabel('Acceleration (ms^-2)');
legend('x','y','z');
print(accelGraph, '-depsc', [file, ' Accelerometer Graph']);