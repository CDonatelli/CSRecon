function data = ReconWholeStack2(filePrefix)

%process video into stack of useful images

imageList = dir('*.JPG') ;
[m,n] = size(imageList);
theta = 180/m;
testImage = imread(imageList(1).name);

figure
imshow(testImage);
[J, rect] = imcrop(testImage);
% if rect(3)>rect(4)
%     rect(3)=rect(4);
% elseif rect(4)>rect(3)
%     rect(4)=rect(3);
% else
%     rect = rect;
% end
% assumes the images is landscape
rect(3) = rect(4);
testImage = imcrop(imread(imageList(1).name),rect);

disp('Getting image dimensions ...')
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
    imFrames(i).cdata = imcrop(imread(imageList(i).name),rect);
end

disp('Calculating Alignment ...')
imFrames = alignStack(imFrames,theta);

%set aside teh memory
disp('Setting aside memory for data structures...')
for i = 1:1:imHeight    
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
for i = 2000:1:2005     % this should be 1:1:size(data,2)
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
%imageExample = imread(imageList(1).name);
%imshow(rowVals);
%output_size = max(size(imageExample));

end

function outFrames = alignStack(inFrames,theta)
%get the first and last frame. Estimate the translation distance between
%them
startFrame = rgb2gray(inFrames(1).cdata);
endFrame = fliplr(rgb2gray(inFrames(end).cdata));
[optimizer, metric] = imregconfig('multimodal');
optimizer.InitialRadius = 0.009;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 100;
tform = imregtform(startFrame,endFrame, 'translation', optimizer, metric);

%%% Comment out between------- to remove loop %%%
aligned = 0;
mult = 1;
while aligned ~= 2
%%%--------------------------------------------------------------%%%
    disp('Aligning Images ...')
    for i = 1:size(inFrames,2)
        outFrames(i).cdata(:,:,1) = imtranslate(inFrames(i).cdata(:,:,1),...
            [mult*(round(tform.T(3,1))/2),0]);
        outFrames(i).cdata(:,:,2) = imtranslate(inFrames(i).cdata(:,:,2),...
            [mult*(round(tform.T(3,1))/2),0]);
        outFrames(i).cdata(:,:,3) = imtranslate(inFrames(i).cdata(:,:,3),...
            [mult*(round(tform.T(3,1))/2),0]);
    end
%%%--------------------------------------------------------------%%%    
    RrowVals = [];GrowVals = [];BrowVals = [];
    
    for i = 1:size(outFrames,2)
        currentImage = outFrames(i).cdata;
        redImage = currentImage(:,:,1);
        greenImage = currentImage(:,:,2);
        blueImage = currentImage(:,:,3);
        
        [rows, cols] = size(redImage);
        RrowVals = [RrowVals; redImage(round(rows/2),:)];
        GrowVals = [GrowVals; greenImage(round(rows/2),:)];
        BrowVals = [BrowVals; blueImage(round(rows/2),:)];

    end
    
    rtestRecondImage = 256*iradon(RrowVals',theta, 'Cosine');
    gtestRecondImage = 256*iradon(GrowVals',theta, 'Cosine');
    btestRecondImage = 256*iradon(BrowVals',theta, 'Cosine');
    testRecondImage = cat(3,rtestRecondImage, gtestRecondImage, btestRecondImage);
    imshow(testRecondImage);
    
    aligned = input('Left(1), Right(3), or does this look OK? (2)');
    if aligned == 1
        mult = mult + 0.1;
    elseif aligned == 3
        mult = mult - 0.1;
    else
        mult = mult;
    end
end
%%%--------------------------------------------------------------%%%
end

