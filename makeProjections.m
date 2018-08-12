%make some projections so we know what a good set looks like
phantomImage = imread('csPhantom.jpg');
phantomImage = phantomImage(:,:,3);
theta = 0:6:178;  
[sinogram,xp] = radon(phantomImage,theta); 
num_angles = size(sinogram,2)

imagesc(theta,xp,sinogram)
colormap(hot)
colorbar
xlabel('Parallel Rotation Angle - \theta (degrees)'); 
ylabel('Parallel Sensor Position - x\prime (pixels)');

% Constrain the output size of each reconstruction to be the same as the
% size of the original image, |P|.
output_size = max(size(phantomImage));

dtheta = theta(2) - theta(1);
reconImage = iradon(sinogram,dtheta,output_size);

figure
imshow(reconImage,[0 255]);
title('Boom like that')