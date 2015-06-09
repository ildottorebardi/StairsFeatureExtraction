clear all;

% Setting the filename
filename = 'alphaData.csv';
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
sensorTimeColumn = csvread(filename,0,4,[0,4,rows-1,4]);

% Creating a new column for adjusted time
adjustedColumn = timeColumn - initialValue;
tauColumn = sensorTimeColumn - timeColumn;

% Writing the new adjusted time column to the RHS of the original CSV file if there are only 5 existing columns within the file
% Would prefer to use csvwrite for consistency but function can only write to 5 degrees of accuracy
columns = size(openFile, 2);
if columns == 6
    dlmwrite(filename,[openFile,adjustedColumn,tauColumn], 'precision',12);
    openFile = [openFile,adjustedColumn,tauColumn];
else
end

%% Parsing through the data array and creating individual matrices for accelerometer, magnetometer and gyroscope data
accelValues = [];
magValues = [];
gyroValues = [];
for i = 1:rows-1
    rowParse = openFile(i,:);
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
% Finding the mean value for tau for each sensor
tauAccel = mean(accelSensorTime);
tauMag = mean(magSensorTime);
tauGyro = mean(gyroSensorTime);