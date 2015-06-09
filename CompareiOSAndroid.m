clearvars -except iUpAcc iUpTime iDownAcc iDownTime iFlatAcc iFlatTime UpAcc UpTime DownAcc DownTime FlatAcc FlatTime

iUpAccNew = iUpAcc(20:1147);
iUpTimeNew = iUpTime(20:1147) - iUpTime(20);

figure;
plot(UpTime, UpAcc);
hold on;
plot(iUpTimeNew, iUpAccNew);
title('Acceleration vs Time for Class 1 Total Acceleration Vector');
xlabel('Time (ms)');
ylabel('Acceleration (ms^-^2)');
legend('Android','iOS - Motion Data Logger');
axis([0,11000,5,19]);

iDownAccNew = iDownAcc(18:1202);
iDownTimeNew = iDownTime(18:1202) - iUpTime(18);

figure;
plot(DownTime, DownAcc);
hold on;
plot(iDownTimeNew, iDownAccNew);
title('Acceleration vs Time for Class 2 Total Acceleration Vector');
xlabel('Time (ms)');
ylabel('Acceleration (ms^-^2)');
legend('Android','iOS - Motion Data Logger');
axis([0,11500,4,20]);

iFlatAccNew = iFlatAcc(12:889);
iFlatTimeNew = iFlatTime(12:889) - iUpTime(12);

figure;
plot(FlatTime, FlatAcc);
hold on;
plot(iFlatTimeNew, iFlatAccNew);
title('Acceleration vs Time for Class 3 Total Acceleration Vector');
xlabel('Time (ms)');
ylabel('Acceleration (ms^-^2)');
legend('Android','iOS - Motion Data Logger');
axis([0,8500,6,16]);