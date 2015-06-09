clear all;

% Setting the filename
filename = 'DomiFlat.csv';
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
accNorm = ((accelX.^2) + (accelY.^2) + (accelZ.^2)).^0.5;
accNormOriginal = accNorm;

% LowPass Filter
initialAcc = accNorm(1);
accRows = size(accNorm, 1);
a = 0.01;

for i = 1:accRows;
    if i == 1;
        accNorm(i) = accNorm(i);
    elseif 2 <= i <= accRows;
        accNorm(i) = a*accNorm(i) + (1 - a)*accNorm(i - 1);
    else
    end
end

% FastFourier Transform
fastFourier = fft(accNormOriginal);
fastFourierLP = fft(accNorm);
ffLength = length(fastFourier);
samplingF = 100;
fAxis = [0:ffLength-1] * samplingF/ffLength;
plot(fAxis,abs(fastFourier));
hold on
plot(fAxis,abs(fastFourierLP));
axis([0.5,samplingF/2,0,30]);
title('Frequency vs. Normalised Acceleration Data After An Applied FFT');
xlabel('Frequency (Hz)');
ylabel('f(acceleration)');
legend('Raw Data','LP Filter');