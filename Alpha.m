% Defining variables
tauAccel = 11.7560975609756; % Time Constant for the accelerometer
T = 50; % Rate at which data is collected, 1/f, where f = 20Hz

% Calculating alpha, for Android...1-standard value
a = tauAccel/(tauAccel + T)