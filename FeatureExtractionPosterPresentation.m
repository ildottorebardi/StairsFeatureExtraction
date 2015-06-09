clear all;

% Specifying the directory of known datafiles
trueDirectory = 'Raw Data/True Android Data/Walking/';
% Specifying the three classes
classes = {'Up','Down','Flat'};

% Set the number of peaks wishing to be counted
peakCount = 4;
NormalisedCalc = 'Yes';
normalisingFactor = 1.2;

for classNum = 1:3
    specDir = strcat(trueDirectory,char(classes(classNum)));

    % Set an empty array for ammassing peak data
    peakValues = [];

    % Defining the accepted file type for reading
    dataFiles = dir(fullfile(specDir,'*.csv'));
    % Counting how many files of the type .csv are within the folder
    fileCount = length(dataFiles);
    % Obtaining the filenames
    filenames = cell(fileCount,1);

    for i = 1:fileCount
        filenames(i) = {dataFiles(i).name};
    end

    % Setting the filename
    for j = 1:fileCount

        filename = char(filenames(j));
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


        % Parsing through the CSV file and creating individual matrices for accelerometer, magnetometer and gyroscope data
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

        % Creating individual columns of the time constants tau for each sensor
        accelSensorTime = accelValues(:,[8]);

        % Applying a filter to prevent anomolies corrupting the calculated tau
        correctedAccelSensorTime = accelSensorTime(accelSensorTime < 30);

        % Finding the mean value of Tau for each sensor
        tauAccel = mean(correctedAccelSensorTime);

        % Creating new matrices of individual columns for X, Y and Z vertices and time, from the acceleration matrix
        accelX = accelValues(:,[1]);
        accelY = accelValues(:,[2]);
        accelZ = accelValues(:,[3]);
        accelTime = abs(accelValues(:,[7]));
        accMag = ((accelX.^2) + (accelY.^2) + (accelZ.^2)).^0.5;
%         accMag = accelZ;
        accMagOriginal = accMag;

        %% LowPass Filter
        initialAcc = accMag(1);
        accRows = size(accMag, 1);
        T = 50; % Rate at which data is collected, 1/f, where f = 20Hz
        % Calculating alpha, for Android...1-standard value
        a = tauAccel/(tauAccel + T);

        for i = 1:accRows;
            if i == 1;
                accMag(i) = accMag(i);
            elseif 2 <= i <= accRows;
                accMag(i) = a*accMag(i) + (1 - a)*accMag(i - 1);
            else
            end
        end

        %% FastFourier Transform
        % Fast Fourier transofmr on original accelerometer data
        fastFourier = fft(accMagOriginal);
        % Fast Fourier transform on Low-Pass Filter data
        fastFourierLP = fft(accMag);
        % Defining the length of the FFT
        ffLength = length(fastFourier);
        % Defining the sampling frequency
        samplingF = 20;
        % Defining the y-axis
        fAxis = [0:ffLength-1] * samplingF/ffLength;

        % Halving the data range as only first half of frequencies can be used
        fftManip = [fAxis.',abs(fastFourier)];
        halfLength = round(length(fftManip)/2);
        fftManip = fftManip([2:halfLength],:);
        % Creating two new arrays to be plotted when using the findpeaks function
        peaksfAxis = fftManip(:,1);
        peaksFastFourier = fftManip(:,2);

        %% Peak Finder
        % Plot the two new axis created
    %     fftGraph = figure;
    %     findpeaks(peaksFastFourier,peaksfAxis)
    %     title('Frequency vs. Normalised Acceleration Data After An Applied FFT');
    %     xlabel('Frequency (Hz)');
    %     ylabel('f(acceleration)');
    %     print(fftGraph, '-depsc',[strcat(specDir,'/findPeaks'),char(file)]);
        % Find the locations of the peaks
        [pks,locs] = findpeaks(peaksFastFourier,peaksfAxis);
        peaksMat = [pks,locs];
        % Rank the peaks in descending order of magnitude
        [~,rank] = sort(peaksMat(:,1),'descend');
        magMat = peaksMat(rank,:);
        % Choose the top n number of peaks
        topN = magMat(1:peakCount,:);
        % Rank these n peaks by their frequency in ascending order
        [~,rank2] = sort(topN(:,2));
        % Present the top n peaks
        arrangedN = topN(rank2,:);
    %     peakValues = [peakValues,arrangedN]; % Peaks in order of frequency
        peakValues = [peakValues,topN]; % Peaks in order of magnitude

    end

    magAdd = [];
    aveMag = [];
    freqAdd = [];
    aveFreq = [];
    for k = 1:fileCount
        magAdd = [magAdd,peakValues(:,2*k-1)];
    end
    for l = 1:peakCount
        avg = sum(magAdd(l,:))/fileCount;
        aveMag = [aveMag;avg];
    end
    for m = 1:fileCount
        freqAdd = [freqAdd,peakValues(:,2*m)];
    end
    for n = 1:peakCount
            avg = sum(freqAdd(n,:))/fileCount;
            aveFreq = [aveFreq;avg];
    end
    
% Create three arrays of "optimal" values for the largest n peaks on the FFT diagrams for the corresponding three classes
    if classNum == 1
        optimalUp = [aveMag,aveFreq];
    elseif classNum == 2
        optimalDown = [aveMag,aveFreq];
    elseif classNum == 3
        optimalFlat = [aveMag,aveFreq];
    else
    end
    
end

clearvars -except optimalUp optimalDown optimalFlat peakCount NormalisedCalc normalisingFactor

testFile = 'Run01.csv';

%% Generating Test Data
% Set an empty array for ammassing test data
peakValues = [];

% for testFile = 1
file=testFile(1:end-4);

% Opening the CSV file
dataArray = csvread(testFile);

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
    dlmwrite(testFile,[dataArray,adjustedColumn,tauColumn], 'precision',12);
    dataArray = [dataArray,adjustedColumn,tauColumn];
else
end

% Parsing through the CSV file and creating individual matrices for accelerometer, magnetometer and gyroscope data
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

% Creating individual columns of the time constants tau for each sensor
accelSensorTime = accelValues(:,[8]);

% Applying a filter to prevent anomolies corrupting the calculated tau
correctedAccelSensorTime = accelSensorTime(accelSensorTime < 30);

% Finding the mean value of Tau for each sensor
tauAccel = mean(correctedAccelSensorTime);

% Creating new matrices of individual columns for X, Y and Z vertices and time, from the acceleration matrix
accelX = accelValues(:,[1]);
accelY = accelValues(:,[2]);
accelZ = accelValues(:,[3]);
accelTime = abs(accelValues(:,[7]));
accMag = ((accelX.^2) + (accelY.^2) + (accelZ.^2)).^0.5;
accMagOriginal = accMag;

%% LowPass Filter
initialAcc = accMag(1);
accRows = size(accMag, 1);
T = 50; % Rate at which data is collected, 1/f, where f = 20Hz
% Calculating alpha, for Android...1-standard value
a = tauAccel/(tauAccel + T);

for i = 1:accRows;
    if i == 1;
        accMag(i) = accMag(i);
    elseif 2 <= i <= accRows;
        accMag(i) = a*accMag(i) + (1 - a)*accMag(i - 1);
    else
    end
end

%% FastFourier Transform
% Fast Fourier transofmr on original accelerometer data
fastFourier = fft(accMagOriginal);
% Fast Fourier transform on Low-Pass Filter data
fastFourierLP = fft(accMag);
% Defining the length of the FFT
ffLength = length(fastFourier);
% Defining the sampling frequency
samplingF = 20;
% Defining the y-axis
fAxis = [0:ffLength-1] * samplingF/ffLength;

% Halving the data range as only first half of frequencies can be used
fftManip = [fAxis.',abs(fastFourier)];
halfLength = round(length(fftManip)/2);
fftManip = fftManip([2:halfLength],:);
% Creating two new arrays to be plotted when using the findpeaks function
peaksfAxis = fftManip(:,1);
peaksFastFourier = fftManip(:,2);

%% Peak Finder
% Plot the two new axis created
%     fftGraph = figure;
%     findpeaks(peaksFastFourier,peaksfAxis)
%     title('Frequency vs. Normalised Acceleration Data After An Applied FFT');
%     xlabel('Frequency (Hz)');
%     ylabel('f(acceleration)');
%     print(fftGraph, '-depsc',[strcat(specDir,'/findPeaks'),char(file)]);
% Find the locations of the peaks
[pks,locs] = findpeaks(peaksFastFourier,peaksfAxis);
peaksMat = [pks,locs];
% Rank the peaks in descending order of magnitude
[~,rank] = sort(peaksMat(:,1),'descend');
magMat = peaksMat(rank,:);
% Choose the top n number of peaks
topN = magMat(1:peakCount,:);
% Rank these n peaks by their frequency in ascending order
[~,rank2] = sort(topN(:,2));
% Present the top n peaks
arrangedN = topN(rank2,:);
%     peakValues = [peakValues,arrangedN]; % Peaks in order of frequency
peakValues = [peakValues,topN];

%% Error Calculations
if strcmp('No',NormalisedCalc) == 1
    % Standard Error Calculation
    deltaUp = abs(optimalUp - peakValues);
    deltaDown = abs(optimalDown - peakValues);
    deltaFlat = abs(optimalFlat - peakValues);
    % Calculating the total error by summing up all error values and /2n
    errorUp = sum(deltaUp(:))/(peakCount*2);
    errorDown = sum(deltaDown(:))/(peakCount*2);
    errorFlat = sum(deltaFlat(:))/(peakCount*2);
elseif strcmp('Yes',NormalisedCalc) == 1
    % Normalised Error Calculation
    % Normalising the test data values
    normPeakValues = [normalisingFactor*peakValues(:,1)/max(peakValues(:,1)),peakValues(:,2)/max(peakValues(:,2))];
    % Normalising the "optimal" data values
    normDeltaUp = [normalisingFactor*optimalUp(:,1)/max(optimalUp(:,1)),optimalUp(:,2)/max(optimalUp(:,2))];
    normDeltaDown = [normalisingFactor*optimalDown(:,1)/max(optimalDown(:,1)),optimalDown(:,2)/max(optimalDown(:,2))];
    normDeltaFlat = [normalisingFactor*optimalFlat(:,1)/max(optimalFlat(:,1)),optimalFlat(:,2)/max(optimalFlat(:,2))];
    % Creating arrays of 2n values of data for the absolute difference between test and true data
    deltaUp = abs(normDeltaUp - normPeakValues);
    deltaDown = abs(normDeltaDown - normPeakValues);
    deltaFlat = abs(normDeltaFlat - normPeakValues);
    % Calculating the total error by summing up all error values and /2n
    errorUp = sum(deltaUp(:))/(peakCount*2)
    errorDown = sum(deltaDown(:))/(peakCount*2)
    errorFlat = sum(deltaFlat(:))/(peakCount*2)
else
end

%% Data Classification
if errorUp < errorDown && errorUp < errorFlat
    disp('The data is of the Up Class')
elseif errorDown < errorUp && errorDown < errorFlat
    disp('The data is of the Down Class')
elseif errorFlat < errorUp && errorFlat < errorDown
    disp('The data is of the Flat Class')
else
end
