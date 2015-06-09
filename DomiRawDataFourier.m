clear all;

% Setting the filename
filename = 'DomiUp.csv';
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

% FastFourier Transform
fastFourier = fft(accelZ);
ffLength = length(fastFourier);
samplingF = 100;
fAxis = [0:ffLength-1] * samplingF/ffLength;
plot(fAxis,abs(fastFourier));
axis([0.5,samplingF/2,0,200]);