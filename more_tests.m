phantomImage = imread('csPhantom.jpg');
P = phantomImage(:,:,3);
imshow(P)
theta1 = 0:10:170; 

[R1,~] = radon(P,theta1); 

num_angles_R1 = size(R1,2)
theta2 = 0:5:175;  
[R2,~] = radon(P,theta2);

num_angles_R2 = size(R2,2)
theta3 = 0:2:178;  
[R3,xp] = radon(P,theta3); 

num_angles_R3 = size(R3,2)
N_R1 = size(R1,1)
imagesc(theta3,xp,R3)

colormap(hot)
colorbar
xlabel('Parallel Rotation Angle - \theta (degrees)'); 
ylabel('Parallel Sensor Position - x\prime (pixels)');
% Constrain the output size of each reconstruction to be the same as the
% size of the original image, |P|.
output_size = max(size(P));

dtheta1 = theta1(2) - theta1(1);
I1 = iradon(R1,dtheta1,output_size);

dtheta2 = theta2(2) - theta2(1);
I2 = iradon(R2,dtheta2,output_size);

dtheta3 = theta3(2) - theta3(1);
I3 = iradon(R3,dtheta3,output_size);

figure
montage({I1,I2,I3},'Size',[1 3])
title('Reconstruction from Parallel Beam Projection with 18, 24, and 90 Projection Angles')