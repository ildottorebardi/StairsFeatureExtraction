dataFiles = dir(fullfile('Raw Data/Android Data/Walking/Up','*.csv'));
% dataFiles = dir('Raw Data/Android Data/Walking/Flat')
fileCount = length(dataFiles);
filenames = cell(fileCount,1);


for i = 1:fileCount
    filenames(i) = {dataFiles(i).name};
end

filenames