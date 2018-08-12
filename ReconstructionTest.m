imageList = dir('*.tif') ;
[m,n] = size(imageList);
theta = 360/m;

RrowVals = [];
GrowVals = [];
BrowVals = [];
for i = 1:1:m
    currentImage = imread(imageList(i).name);
    RedImage = currentImage(:,:,1);
    GreenImage = currentImage(:,:,2);
    BlueImage = currentImage(:,:,3);
    %[imageM, imageN] = size(3,RedImage, GreenImage, BlueImage);
    RrowVals = [RrowVals; RedImage(500,:)];
    GrowVals = [GrowVals; GreenImage(500,:)];
    BrowVals = [BrowVals; BlueImage(500,:)];
    
end
imageExample = imread(imageList(1).name);
%imshow(rowVals);
output_size = max(size(imageExample));

%imagesc(rowVals)
% colormap(hot)
% colorbar
% xlabel('Parallel Rotation Angle - \theta (degrees)'); 
% ylabel('Parallel Sensor Position - x\prime (pixels)');

%[projections, Xp] = radon(rowVals,theta);

RrecondImage = iradon(RrowVals',theta, 'Cosine');
GrecondImage = iradon(GrowVals',theta, 'Cosine');
BrecondImage = iradon(BrowVals',theta, 'Cosine');
recondImage = cat(3,RrecondImage, GrecondImage, BrecondImage);
imshow(recondImage)