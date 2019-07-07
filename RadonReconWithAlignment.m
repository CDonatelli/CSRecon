function [data, reconTime] = RadonReconWithAlignment(filePrefix)

%process video into stack of useful images

imageList = dir('*.JPG') ;
[m,n] = size(imageList);
theta = 180/m;
testImage = imread(imageList(1).name);
% testImage = undistortImage(testImage,cameraParams);

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
testImage = imcrop(testImage,rect);

disp('Getting image dimensions ...')
imHeight = size(testImage,1);
imWidth = size(testImage,2);

%read in the frames to a structure
%when the loop is done there will be a structure with as many entries as
%there are movie frames. The structure will have a cdata field with teh
%image data and a cmap field with the color map
imFramesOG = struct('cdata',zeros(imHeight,imWidth,3,'uint8'),...
    'colormap',[]);
scaledFrames = struct('cdata',zeros(imHeight,imWidth,3,'uint8'),...
    'colormap',[]);

disp('Creating Image Frame Structure ...')
for i = 1:m
    imFramesOG(i).cdata = imcrop(imread(imageList(i).name),rect);
%     imFrames(i).cdata = imcrop(undistortImage(imread(imageList(i).name),cameraParams),rect);
%     scaledFrames(i).cdata = imresize(imcrop(undistortImage(imread(imageList(i).name),cameraParams),rect),0.2);
    scaledFrames(i).cdata = imresize(imcrop(imread(imageList(i).name),rect),0.25);  
    imshow(imFramesOG(i).cdata);
end

disp('Calculating Alignment ...')
mult1 = adjustAlignment(scaledFrames,theta, 0.15);
mult2 = adjustAlignment(scaledFrames,theta, 0.50);
mult3 = adjustAlignment(scaledFrames,theta, 0.85);

p = polyfit(0.25*[0.15*imHeight,0.5*imHeight,0.85*imHeight], [mult1, mult2, mult3],1);
slope = p(1);
maxAngle = atand(slope);
angles = linspace(0,maxAngle,m);

disp('Applying Alignment to full stack ...')
imFramesOG = alignStack(imFramesOG,theta,mult2,angles);

[J, rect2] = imcrop(imFramesOG(end).cdata);
rect2(3) = rect2(4);

imHeight = size(J,1);
imWidth = size(J,2);
scaledFrames = struct('cdata',zeros(imHeight,imHeight,3,'uint8'),...
    'colormap',[]);
imFrames = struct('cdata',zeros(imHeight,imHeight,3,'uint8'),...
    'colormap',[]);

disp('Re-cropping rotated images')
for i = 1:m
    imFrames(i).cdata = imcrop(imFramesOG(i).cdata,rect2);
    scaledFrames(i).cdata = imresize(imFrames(i).cdata,0.25);  
end

mult5 = adjustAlignment(scaledFrames,theta, 0.50);
angles5 = zeros(1,360);

disp('Applying New Alignment to full stack ...')
imFrames = alignStack(imFrames,theta,mult5,angles5);

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
currentDirectory = pwd;
directoryString = [filePrefix,'_slices'];
redDirString = [filePrefix,'_redSlices'];
greDirString = [filePrefix,'_greSlices'];
bluDirString = [filePrefix,'_bluSlices'];
mkdir(directoryString)
%mkdir(redDirString)
%mkdir(greDirString)
%mkdir(bluDirString)

%cd(directoryString)
disp('Reconstructing the images ...')
tic
%figure

for i = 1:1:size(data,2)  % this should be 1:1:size(data,2)
    rRecondImage = 256*iradon(data(i).RrowVals',theta, 'Cosine');
    gRecondImage = 256*iradon(data(i).GrowVals',theta, 'Cosine');
    bRecondImage = 256*iradon(data(i).BrowVals',theta, 'Cosine');
    
    %imwrite(rRecondImage, [pwd,'\',redDirString, '\Red', filePrefix,'_', num2str(i,'%03i'),'.tif'],'tif')
    %imwrite(gRecondImage, [pwd,'\',greDirString, '\Gre', filePrefix,'_', num2str(i,'%03i'),'.tif'],'tif')
    %imwrite(bRecondImage, [pwd,'\',bluDirString, '\Blu', filePrefix,'_', num2str(i,'%03i'),'.tif'],'tif')
    
    recondImage = cat(3,rRecondImage,gRecondImage, bRecondImage);
    %imshow(recondImage);
    imwrite(recondImage, [pwd,'\',directoryString, '\', filePrefix,'_', num2str(i,'%03i'),'.tif'],'tif')
    disp(['Reconstruction ', num2str(i), ' out of ', num2str(size(data,2)), ' complete.'])
end
reconTime = toc
%cd ..
%imageExample = imread(imageList(1).name);
%imshow(rowVals);
%output_size = max(size(imageExample));

end

function outFrames = alignStack(inFrames,theta, mult, angles)
%get the first and last frame. Estimate the translation distance between
%them
% startFrame = rgb2gray(inFrames(1).cdata);
% endFrame = fliplr(rgb2gray(inFrames(end).cdata));
% [optimizer, metric] = imregconfig('multimodal');
% optimizer.InitialRadius = 0.009;
% optimizer.Epsilon = 1.5e-4;
% optimizer.GrowthFactor = 1.01;
% optimizer.MaximumIterations = 100;
% tform = imregtform(startFrame,endFrame, 'translation', optimizer, metric);

disp('Aligning Images ...')
frNum = size(inFrames,2);
    for i = 1:frNum
        inFrames(i).cdata(:,:,1) = imtranslate(inFrames(i).cdata(:,:,1), ...
            [mult,0]);
        inFrames(i).cdata(:,:,2) = imtranslate(inFrames(i).cdata(:,:,2), ...
            [mult,0]);
        inFrames(i).cdata(:,:,3) = imtranslate(inFrames(i).cdata(:,:,3), ...
            [mult,0]);
    end

    for i = 1:frNum
        outFrames(i).cdata(:,:,1) = imrotate(inFrames(i).cdata(:,:,1), angles(i));
        outFrames(i).cdata(:,:,2) = imrotate(inFrames(i).cdata(:,:,2), angles(i));
        outFrames(i).cdata(:,:,3) = imrotate(inFrames(i).cdata(:,:,3), angles(i));
    end
    
end

function mult = adjustAlignment(inFrames,theta, slice)
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

aligned = 0;
mult = round(tform.T(3,1)/2);
while aligned ~= 3
    disp('Aligning Images ...')
    frNum = size(inFrames,2);
    for i = 1:frNum
        outFrames(i).cdata(:,:,1) = imtranslate(inFrames(i).cdata(:,:,1),...
            [mult,0]);
        outFrames(i).cdata(:,:,2) = imtranslate(inFrames(i).cdata(:,:,2),...
            [mult,0]);
        outFrames(i).cdata(:,:,3) = imtranslate(inFrames(i).cdata(:,:,3),...
            [mult,0]);
    end
    RrowVals = [];GrowVals = [];BrowVals = [];
    
    for i = 1:size(outFrames,2)
        currentImage = outFrames(i).cdata;
        redImage = currentImage(:,:,1);
        greenImage = currentImage(:,:,2);
        blueImage = currentImage(:,:,3);
        
        [rows, cols] = size(redImage);
        RrowVals = [RrowVals; redImage(round(slice*rows),:)];
        GrowVals = [GrowVals; greenImage(round(slice*rows),:)];
        BrowVals = [BrowVals; blueImage(round(slice*rows),:)];  
    end     
    
    rtestRecondImage = 256*iradon(RrowVals',theta, 'Cosine');
    gtestRecondImage = 256*iradon(GrowVals',theta, 'Cosine');
    btestRecondImage = 256*iradon(BrowVals',theta, 'Cosine');
    testRecondImage = cat(3,rtestRecondImage, gtestRecondImage, btestRecondImage);
    imshow(testRecondImage);
    
    aligned = input('Left(1,2), Right(4,5), or does this look OK? (3)');
    if aligned == 1
        mult = mult + 10;
    elseif aligned == 2
        mult = mult + 1;
    elseif aligned == 3
        mult = mult;
    elseif aligned == 4
        mult = mult - 1;
    elseif aligned == 5
        mult = mult -10;
    end
end
end

function outFrames = deWarpImages(inFrames)



end
