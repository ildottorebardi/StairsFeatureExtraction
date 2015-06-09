clear all;

% Setting the filename
filename = 'DomFlat.csv';
file=filename(1:end-4);

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
    rowParse = csvread(filename,i,0,[i,0,i,5]);
    if rowParse(5) == 777777;
        accelValues = [accelValues; rowParse];
    elseif rowParse(5) == 888888;
        magValues = [magValues; rowParse];
    elseif rowParse(5) == 999999;
        gyroValues = [gyroValues; rowParse];
    else
    end
end
% disp(gyroValues);

% Creating new matrices of individual columns for X, Y and Z vertices and time, from the acceleration matrix
accelX = accelValues(:,[1]);
accelY = accelValues(:,[2]);
accelZ = accelValues(:,[3]);
accelTime = accelValues(:,[6]);
accelTotal = ((accelX.^2) + (accelY.^2) + (accelZ.^2)).^0.5;

% FastFourier Transform
fastFourier = fft(accelTotal);
% Defining the length of the FFT
ffLength = length(fastFourier);
% Defining the sampling frequency
samplingF = 20;
% Defining the f-axis
fAxis = [0:ffLength-1] * samplingF/ffLength;
% Plotting the absolute values of the FFT
plot(fAxis,abs(fastFourier));
% Defining the axis lengths
axis([0.5,samplingF/2,0,25]);
title('FFT Plot for Walking on a Flat Surface');
xlabel('Frequency (Hz)');
ylabel('f(Frequency)');

% Creating new matrices of individual columns for X, Y and Z vertices and time, from the magnetometer matrix
magX = magValues(:,[1]);
magY = magValues(:,[2]);
magZ = magValues(:,[3]);
magTime = magValues(:,[6]);

% Creating new matrices of individual columns for X, Y and Z vertices and time, from the gyroscope matrix
gyroX = gyroValues(:,[1]);
gyroY = gyroValues(:,[2]);
gyroZ = gyroValues(:,[3]);
gyroTime = gyroValues(:,[6]);