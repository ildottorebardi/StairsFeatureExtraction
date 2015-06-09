clear all;

% Setting the filename
filename = 'testData3.csv';
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
sensorTimeColumn = openFile(:,[5]);
% disp(timeColumn);

% Creating a new column for adjusted time
adjustedColumn = timeColumn - initialValue;
tauColumn = sensorTimeColumn - timeColumn;
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
 %% Creating individual columns of the time constants tau for each sensor
    accelSensorTime = accelValues(:,[8]);
    magSensorTime = magValues(:,[8]);
    gyroSensorTime = gyroValues(:,[8]);

    % Applying a filter to prevent anomolies corrupting the calculated tau
    correctedAccelSensorTime = accelSensorTime(accelSensorTime < 30);
    correctedMagSensorTime = magSensorTime(magSensorTime < 30);
    correctedGyroSensorTime = gyroSensorTime(gyroSensorTime < 30);

    % Finding the mean value of Tau for each sensor
    tauAccel = mean(correctedAccelSensorTime);
    tauMag = mean(correctedMagSensorTime);
    tauGyro = mean(correctedGyroSensorTime);

    %% Creating new matrices of individual columns for X, Y and Z vertices and time, from the acceleration matrix
    accelX = accelValues(:,[1]);
    accelY = accelValues(:,[2]);
    accelZ = accelValues(:,[3]);
    accelNorm = ((accelX.^2) + (accelY.^2) + (accelZ.^2)).^0.5;
    accelTime = abs(accelValues(:,[7]));
    accelNormOriginal = accelNorm;

    % LowPass Filter
    initialAcc = accelNorm(1);
    accelRows = size(accelNorm, 1);
    T = 50; % Rate at which data is collected, 1/f, where f = 20Hz
    % Calculating alpha, for Android...1-standard value
    a = tauAccel/(tauAccel + T);

    for i = 1:accelRows;
        if i == 1;
            accelNorm(i) = accelNorm(i);
        elseif 2 <= i <= accelRows;
            accelNorm(i) = a*accelNorm(i) + (1 - a)*accelNorm(i - 1);
        else
        end
    end
    

% FastFourier Transform
fastFourier = fft(accNormOriginal);
fastFourierLP = fft(accNorm);
ffLength = length(fastFourier);
samplingF = 20;
fAxis = [0:ffLength-1] * samplingF/ffLength;
plot(fAxis,abs(fastFourier));
hold on
plot(fAxis,abs(fastFourierLP));
axis([0.5,samplingF/2,0,25]);
title('Frequency vs. Normalised Acceleration Data After An Applied FFT');
xlabel('Frequency (Hz)');
ylabel('f(acceleration)');
legend('Raw Data','LP Filter');