function data = ReconWholeStack()

%process video into stack of useful images

%create a movie object so it is readable
waitfor(msgbox('Select Your Video File'));
videoFile = uigetfile();
vidObj = VideoReader(videoFile);

disp('Geting video dimensions ...')
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;

%read in the movie frames to a structure
%when the loop is done there will be a structure with as many entries as
%there are movie frames. The structure will have a cdata field with teh
%image data and a cmap field with the color map
movieFrames = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
k = 1;
disp('Creating Video Frame Structure ...')
while hasFrame(vidObj)
    movieFrames(k).cdata = readFrame(vidObj);
    k = k+1;
end

% imageList = dir('*.tif') ;
m = size(movieFrames,2);
theta = 360/m;

%set aside teh memory
disp('Setting aside memory for data structures...')
for i = 1:1:m    
    data(i).RrowVals = [];
    data(i).GrowVals = [];
    data(i).BrowVals = [];
end

% make the sinograms
disp('Making the sinograms ...')
for i = 1:1:m
    currentImage = movieFrames(i).cdata;
    redImage = currentImage(:,:,1);
    greenImage = currentImage(:,:,2);
    blueImage = currentImage(:,:,3);
    for j = 1:1:size(redImage,1)
        data(j).RrowVals = [data(j).RrowVals; redImage(j,:)];
        data(j).GrowVals = [data(j).GrowVals; greenImage(j,:)];
        data(j).BrowVals = [data(j).BrowVals; blueImage(j,:)];
    end
    disp(['Sinogram ', num2str(i), ' out of ', num2str(m), ' complete.'])
end

% make the individual channels and the RGB image
directoryString = [videoFile(1:end-4),'_slices'];
mkdir(directoryString)
cd(directoryString)
disp('Reconstructing the images ...')
for i = 1:1:size(data,2)
    data(i).rRecondImage = iradon(data(i).RrowVals',theta, 'Cosine');
    data(i).gRecondImage = iradon(data(i).GrowVals',theta, 'Cosine');
    data(i).bRecondImage = iradon(data(i).BrowVals',theta, 'Cosine');
    data(i).recondImage = cat(3,data(i).rRecondImage,...
        data(i).gRecondImage, data(i).bRecondImage);
    imshow(data(i).recondImage);
    saveas(gcf, [videoFile(1:end-4),'_', num2str(i,'%03i'),'.tif'])
    disp(['Reconstruction ', num2str(i), ' out of ', num2str(size(data,2)), ' complete.'])
end
cd ..
imageExample = imread(imageList(1).name);
%imshow(rowVals);
output_size = max(size(imageExample));

end
