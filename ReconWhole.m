%process video into stack of useful images

%create a movie object so it is readable
vidObj = VideoReader('magnet2.mp4');
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;

%read in the movie frames to a structure
%when the loop is done there will be a structure with as many entries as
%there are movie frames. The structure will have a cdata field with teh
%image data and a cmap field with the color map
movieFrames = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
k = 1;
while hasFrame(vidObj)
    movieFrames(k).cdata = readFrame(vidObj);
    k = k+1;
end

% imageList = dir('*.tif') ;
m = size(movieFrames,2);
theta = 360/m;

%set aside teh memory
for i = 1:1:m    
    data(i).RrowVals = [];
    data(i).GrowVals = [];
    data(i).BrowVals = [];
end


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
    i
end

movieFrames(j).RrecondImage = iradon(RrowVals',theta, 'Cosine');
%     GrecondImage = iradon(GrowVals',theta, 'Cosine');
%     BrecondImage = iradon(BrowVals',theta, 'Cosine');
%     movieFrames(j).recondImage = cat(3,RrecondImage, GrecondImage, BrecondImage);
%     imshow(movieFrames(j).recondImage)

imageExample = imread(imageList(1).name);
%imshow(rowVals);
output_size = max(size(imageExample));

%imagesc(rowVals)
% colormap(hot)
% colorbar
% xlabel('Parallel Rotation Angle - \theta (degrees)'); 
% ylabel('Parallel Sensor Position - x\prime (pixels)');

%[projections, Xp] = radon(rowVals,theta);
