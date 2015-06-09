clear all;

% Setting the filename
filename = 'DomUp.csv';
disp(filename);
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
ylabel('Acceleration (ms^-^2)');
legend('x','y','z');
print(accelGraph, '-depsc', [file, ' Accelerometer Graph']);

% Plotting a graph of magnetic field strength in Am^-1 against time in milliseconds for the three different vertices,
% then saving the graph with the original .csv filename with "Magnetometer Graph" on the end
magGraph = figure;
plot(magTime, magX);
hold on
plot(magTime, magY);
hold on
plot(magTime, magZ);
title('Magnetic Field Strength vs Time for Magnetic Field in the X, Y & Z Vertices');
xlabel('Time (ms)');
ylabel('Magnetic Field Strength (Am^-1)');
legend('x','y','z');
print(magGraph, '-depsc', [file, ' Magnetometer Graph']);

% Plotting a graph of angular velocity in radsec^-1 against time in milliseconds for the three different vertices,
% then saving the graph with the original .csv filename with "Gyroscope Graph" on the end
gyroGraph = figure;
plot(gyroTime, gyroX);
hold on
plot(gyroTime, gyroY);
hold on
plot(gyroTime, gyroZ);
title('Angular Velocity vs Time from Gyroscope in the X, Y & Z Vertices');
xlabel('Time (ms)');
ylabel('Angular Velocity (radsec^-1)');
legend('x','y','z');
print(gyroGraph, '-depsc', [file, ' Gyroscope Graph']);