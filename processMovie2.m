%process video into stack of useful images

%create a movie object so it is readable
vidObj = VideoReader('lumpy1.m4v');
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;

%read in the movie frames to a structure
%when the loop is done there will be a structure with as many entries as
%there are movie frames. The structure will have a cdata field with the
%image data and a cmap field with the color map.
% I think the iradon transform will need square input, so each frame is
% padded with the appropriate number of images. This assumes that width of
% image is larger than height and both are even numbers.
movieFrames = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
framePadding = (vidObj.Width-vidObj.Height);
k = 1;
while hasFrame(vidObj)
    movieFrames(k).cdata = imtranslate(readFrame(vidObj),[0 framePadding],... 
        'FillValues', 255, 'OutputView', 'full');
    k = k+1;
end

%We need to make sure the frames are 'aligned'. Here that means that the
%center of rotation is in the center of the image. If it is off ny more
%than a pixel or two the radon transform will return garbage. 
%my strategy is to find two fields that are 180 degrees apart by comparing
%a reference image to the mirror image of other images until I get the best
%match. Then find the centroid of the darkest object in each image and the
%difference between the centroids in the axis of rotation.

%simpleminded approach to finding two frames 180 degrees out of phase
%sum all the elements in RGB space of the difference between image 1 and
%the current image
%track the frame number with the minimum difference, that should be the one
%180 degrees different. In an ideal world, the difference would sum to
%zero....perfect overlap.

totalDiff = sum(sum(sum(movieFrames(1).cdata-fliplr(movieFrames(1).cdata),1),2),3);
diffFrameNum = 0;
for i = 1:size(movieFrames,2)
    diffFrame = movieFrames(1).cdata-fliplr(movieFrames(i).cdata);
    imshow(diffFrame);
%    pause(1);
    currentDiff = sum(sum(sum(diffFrame,1),2),3);
    if (currentDiff < totalDiff)
        totalDiff = currentDiff;
        diffFrameNum = i;
    end
end
%this variable is the image closest to 180degrees from first frame
frame180 = movieFrames(diffFrameNum).cdata;
frame0 = movieFrames(1).cdata;

%Since this is generated from amovie ratehr than single images the previous
%code rpovides us with a window in to the spacing of the images. We know
%how many frames make up 180 degrees since the two images that match best
%are 180 degrees apart.
theta = 180 / diffFrameNum;

%now compare the position of the centroid for the two images and use that
%to find the axis of rotation. This code assumes that axis is vertical.
BWframe0 = imcomplement(im2bw (frame0,graythresh(frame0)));
BWframe180 = imcomplement(im2bw (frame180,graythresh(frame0))); %use the same threshold for both images

frame0Stats = regionprops(BWframe0, 'centroid', 'FilledArea');
frame180Stats = regionprops(BWframe180, 'centroid', 'FilledArea');


%now I am just being an ass.  What I wasnt is the index of the largest area
%and the x centroid value for that index. But...istead I am just kludging.
%In both images I have it is region 2
%FIX THIS it is just syntax
rotationAxis = frame180Stats(2).Centroid(1) + (frame0Stats(2).Centroid(1) - frame180Stats(2).Centroid(1))/2;
rotationOffset = size(BWframe0,2)/2 - rotationAxis;

%show what happened
imshow(BWframe0); hold on;
plot(frame0Stats(5).Centroid(1),frame0Stats(2).Centroid(2),'ro');
hold off;
pause (1);

imshow(BWframe180); hold on;
plot(frame180Stats(6).Centroid(1),frame180Stats(2).Centroid(2),'ro');
plot(rotationAxis,(1:size(BWframe0,2)),'.b')
pause (1);

imshow(BWframe180); hold on;
plot(frame180Stats(2).Centroid(1),frame180Stats(2).Centroid(2),'ro');
plot(rotationAxis,(1:size(BWframe0,2)),'.b')
pause (1);

%show the actual rotation axis
plot(size(BWframe0,2)/2,(1:size(BWframe0,2)),'.g');

%show where the cut will be
%plot((1:size(BWframe0,1)),round(size(BWframe0,1)/2),'.r');
hold off;

%make a stack of the images that will be used to reconstruct the model
for i = 1:1:diffFrameNum
    projectionImages(i).cdata = movieFrames(i).cdata(:,:,1);
end       

%make the sinograms. 
output_size = round(max(size(movieFrames(1).cdata))/2^.5); %size out the output image from iradon
sliceLocation = 1650; %location where slice is taken #483 runs through the marker

alignCenter = 0;
alignTop = 6;
numAligns = 10;
for i = 1:1:numAligns %10 iterations
    alignment = (alignCenter-alignTop) + (2*i * ((alignTop-alignCenter)/numAligns));
    sino = makeSinogram(projectionImages, sliceLocation, alignment);
    data(i).sino = sino;
    imshow(iradon(data(i).sino', [], 'spline','Hamming', output_size));
    pause(5);
end

pause(12)

return


function sino = makeSinogram(imageStack, slice, alignment)
%this will take an image stack, offset it by the alignment and return a
%sinogram at a slice location
    sino = [];
    for i = 1:1:size(imageStack,2)
        currentImage = imtranslate(imageStack(i).cdata,[alignment, 0]);
        sino = [sino; currentImage(slice,:)];
    end
end

        
        
    
    
    