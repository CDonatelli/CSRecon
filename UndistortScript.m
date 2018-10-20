imshow(cal1)
[x1,y1] = getpts
close all
%5 columns, 4 rows
imshow(cal2)
[x2,y2] = getpts;
close all

imshow(cal3)
[x3,y3] = getpts;
close all

imagePoints = cat(3,[x1,y1],[x2,y2],[x3,y3]);

boardSize = [6,7];
squareSize = 4;
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

imageSize = [size(I,1),size(I,2)];
cameraParams = estimateCameraParameters(imagePoints,worldPoints,'ImageSize',imageSize);

J1 = undistortImage(I,cameraParams);
imshow(J1)