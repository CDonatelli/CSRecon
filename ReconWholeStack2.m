function data = ReconWholeStack2(filePrefix)

%process video into stack of useful images

imageList = dir('*.JPG') ;
[m,n] = size(imageList);
theta = 180/m;
testImage = imread(imageList(1).name);

disp('Geting image dimensions ...')
imHeight = size(testImage,1);
imWidth = size(testImage,2);

%read in the movie frames to a structure
%when the loop is done there will be a structure with as many entries as
%there are movie frames. The structure will have a cdata field with teh
%image data and a cmap field with the color map
imFrames = struct('cdata',zeros(imHeight,imWidth,3,'uint8'),...
    'colormap',[]);

disp('Creating Image Frame Structure ...')
for i = 1:m
    imFrames(i).cdata = imRead(imageList(i).name);
end

theta = 180/m;

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
    currentImage = imFrames(i).cdata;
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
directoryString = [filePrefix,'_slices'];
mkdir(directoryString)
cd(directoryString)
disp('Reconstructing the images ...')
for i = 1:1:size(data,2)
    data(i).rRecondImage = 256*iradon(data(i).RrowVals',theta, 'Cosine');
    data(i).gRecondImage = 256*iradon(data(i).GrowVals',theta, 'Cosine');
    data(i).bRecondImage = 256*iradon(data(i).BrowVals',theta, 'Cosine');
    data(i).recondImage = cat(3,data(i).rRecondImage,...
        data(i).gRecondImage, data(i).bRecondImage);
    imshow(data(i).recondImage);
    saveas(gcf, [filePrefix,'_', num2str(i,'%03i'),'.tif'])
    disp(['Reconstruction ', num2str(i), ' out of ', num2str(size(data,2)), ' complete.'])
end
cd ..
imageExample = imread(imageList(1).name);
%imshow(rowVals);
output_size = max(size(imageExample));

end
