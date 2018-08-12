
%process video into stack of useful images

%create a movie object so it is readable
vidObj = VideoReader('magnet1.mp4');
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

rowVals = [];
for i = 1:1:size(movieFrames,2)
    currentImage = movieFrames(i).cdata;
    blueImage = currentImage(:,:,3);
    [imageM, imageN] = size(blueImage);
    rowVals = [rowVals; blueImage(round(size(blueImage,2)/2),:)];
end
imageExample = movieFrames(1).cdata;
imshow(rowVals);
output_size = max(size(imageExample));

imagesc(rowVals)
colormap(hot)
colorbar
xlabel('Parallel Rotation Angle - \theta (degrees)'); 
ylabel('Parallel Sensor Position - x\prime (pixels)');


%[projections, Xp] = radon(rowVals,theta);

recondImage = iradon(rowVals', output_size);

imshow(recondImage)