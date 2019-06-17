
names = dir('*.fcsv');

Points = {};

% numPts = input('how many points are in each file? :');
numPts = 7;

for i = 1:length(names)-1
    filename = names(i).name;
    species = filename(1:end-8);
    perc = filename(end-6:end-5);
    
    %Read In File
    %filename = 'Z:\Donatelli\Elongate Fish Vert Mechanics\Raw data - ...
    %            CT Files\0.1Measurements-Kylene\AnoplarchusInsignis001.20%.fcsv';
    delimiter = ',';
    startRow = 4;
    formatSpec = '%*s%f%f%f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
                'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fileID);
    XYZpts = [dataArray{1:end-1}];
    
    XYpts = [XYZpts(:,3),XYZpts(:,1)];
    XYptsTransform = [];
    for j = 1:numPts
        XYptsTransform = [XYptsTransform,XYpts(j,:)];
    end
    
    % Clear temporary variables
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
    
    Points = [Points; [species, perc, num2cell(XYptsTransform)]];
end

prompt = {'Filename:'};
dlgtitle = 'Please name your file';
dims = [1 45];
answer = inputdlg(prompt,dlgtitle,dims)

xlswrite(cell2mat(answer(1)),Points)

