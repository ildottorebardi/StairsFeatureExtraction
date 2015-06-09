clear all;

specDir = 'Raw Data/True Android Data/Walking/Flat';

dataFiles = dir(fullfile(specDir,'*.csv'));
fileCount = length(dataFiles);
filenames = cell(fileCount,1);

for i = 1:fileCount
    filenames(i) = {dataFiles(i).name};
end

% Setting the filename
%for j = 1:fileCount
    
    filename = char(filenames(1));
    file=filename(1:end-4);

    % Opening the CSV file
    dataArray = csvread(strcat(specDir,'/',filename));

    % Finding a value for initial time based on the phone's internal clock
    format long g;
    initialValue = dataArray(1,4);

    % Reading the 4th (time) column within the CSV file
    rows = size(dataArray,1);
    timeColumn = dataArray(:,[4]);
    sensorTimeColumn = dataArray(:,[5]);

    % Creating a new column for adjusted time
    adjustedColumn = timeColumn - initialValue;
    tauColumn = sensorTimeColumn - timeColumn;

    % Writing the new adjusted time column to the RHS of the original CSV file if there are only 5 existing columns within the file
    % Would prefer to use csvwrite for consistency but function can only write to 5 degrees of accuracy
    columns = size(dataArray, 2);
    if columns == 6
        dlmwrite(strcat(specDir,'/',filename),[dataArray,adjustedColumn,tauColumn], 'precision',12);
        dataArray = [dataArray,adjustedColumn,tauColumn];
    else
    end

    %% Parsing through the data array and creating individual matrices for accelerometer, magnetometer and gyroscope data
    accelValues = [];
    magValues = [];
    gyroValues = [];
    for i = 1:rows
        rowParse = dataArray(i,:);
        if rowParse(6) == 777777;
            accelValues = [accelValues; rowParse];
        elseif rowParse(6) == 888888;
            magValues = [magValues; rowParse];
        elseif rowParse(6) == 999999;
            gyroValues = [gyroValues; rowParse];
        else
        end
    end

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
    

    % Creating new matrices of individual columns for X, Y and Z vertices and time, from the magnetometer matrix
    magX = magValues(:,[1]);
    magY = magValues(:,[2]);
    magZ = magValues(:,[3]);
    magNorm = ((magX.^2) + (magY.^2) + (magZ.^2)).^0.5;
    magTime = magValues(:,[7]);

    % Creating new matrices of individual columns for X, Y and Z vertices and time, from the gyroscope matrix
    gyroX = gyroValues(:,[1]);
    gyroY = gyroValues(:,[2]);
    gyroZ = gyroValues(:,[3]);
    gyroNorm = ((gyroX.^2) + (gyroY.^2) + (gyroZ.^2)).^0.5;
    gyroTime = gyroValues(:,[7]);
    
%     % Double Plot
%     accelGraph = figure;  % Comment this for a grouped plot
%     plot(accelTime, accelNorm);
%     hold on;
%     plot(accelTime, accelNormOriginal);
%     title('Acceleration & Filtered Acceleration vs Time for Acceleration in the X, Y & Z Vertices');
%     xlabel('Time (ms)');
%     ylabel('Acceleration (ms^-2)');
%     legend('Filtered Acceleration','Acceleration');
% %     print(accelGraph, '-depsc',[strcat(specDir,'/LPFilterVsRawData'),char(file)]);  % Comment this for a grouped plot
%     hold on;
%     
    % Single Plot
%     accelGraph = figure;  % Comment this for a grouped plot
%     plot(accelTime, accelNorm);
%     title('Filtered Acceleration vs Time for Acceleration in the X, Y & Z Vertices');
%     xlabel('Time (ms)');
%     ylabel('Acceleration (ms^-2)');
%     print(accelGraph, '-depsc',[strcat(specDir,'/LPFilterData'),char(file)]);  % Comment this for a grouped plot
%     hold on;
    
    % FastFourier Transform
    % accelGraph = figure;  % Comment this for a grouped plot
    fastFourier = fft(accelNormOriginal);
    fastFourierLP = fft(accelNorm);
    ffLength = length(fastFourierLP);
    samplingF = 20;
    fAxis = [0:ffLength-1] * samplingF/ffLength;
%     plot(fAxis,abs(fastFourier));
%     hold on
%     plot(fAxis,abs(fastFourierLP));
%     hold on
%     axis([0.5,samplingF/2,0,25]);
%      title('Class 3 Data Runs After An LP Filter & An Applied FFT');
%      xlabel('Frequency (Hz)');
%      ylabel('f(frequency)');
%     legend('Normal Walking Pace','Higher Pace');
%     print(accelGraph, '-depsc',[strcat(specDir,'/FFTData'),char(file)]);  % Comment this for a grouped plot

% Halving the data range as only first half of frequencies can be used
fftManip = [fAxis.',abs(fastFourierLP)];
halfLength = round(length(fftManip)/2);
fftManip = fftManip([2:halfLength],:);
% Creating two new arrays to be plotted when using the findpeaks function
peaksfAxis = fftManip(:,1);
peaksFastFourier = fftManip(:,2);

%% Peak Finder
% Plot the two new axis created
    fftGraph = figure;
    findpeaks(peaksFastFourier,peaksfAxis)
    title('findpeaks Used After An LP Filter & An FFT For Class 3 Data');
    xlabel('Frequency (Hz)');
    ylabel('f(frequency)');
    axis([0.5,samplingF/2,0,25]);

%end

% legend(filenames);  % Comment this for single plots
% print('-depsc',[strcat(specDir,'/'),'FFT Combined Graph']);  % Comment this for single plots