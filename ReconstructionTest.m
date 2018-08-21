imageList = dir('*.JPG') ;
[m,n] = size(imageList);
theta = 180/m;

RrowVals = [];
GrowVals = [];
BrowVals = [];
for i = 1:1:m
    currentImage = imread(imageList(i).name);
    RedImage = currentImage(:,:,1);
    GreenImage = currentImage(:,:,2);
    BlueImage = currentImage(:,:,3);
    %[imageM, imageN] = size(3,RedImage, GreenImage, BlueImage);
    RrowVals = [RrowVals; RedImage(2000,:)];
    GrowVals = [GrowVals; GreenImage(2000,:)];
    BrowVals = [BrowVals; BlueImage(2000,:)];
    
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

RrecondImage = 256*iradon(RrowVals',theta, 'Cosine');
GrecondImage = 256*iradon(GrowVals',theta, 'Cosine');
BrecondImage = 256*iradon(BrowVals',theta, 'Cosine');
recondImage = cat(3,RrecondImage, GrecondImage, BrecondImage);
imshow(recondImage)