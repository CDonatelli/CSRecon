

imageList = dir('*.tif') ;
[m,n] = size(imageList);

currentDirectory = pwd;
directoryString = 'CFHires005grey_slices';
mkdir(directoryString)

for i = 1:m
    currentIm = imread(imageList(i).name);
    currentIm = rgb2gray(currentIm);
    imwrite(currentIm, [pwd,'\',directoryString, '\CFHires005grey_', num2str(i,'%04i'),'.tif'],'tif')
end

% Create Sinogram Figures
[Rr, xpr] = radon(rRecondImage, Dtheta);
[Rg, xpg] = radon(gRecondImage, Dtheta);
[Rb, xpb] = radon(bRecondImage, Dtheta);
figure, imagesc(Dtheta,xpr,Rr); colormap(hot); colorbar(); caxis([-120000 80000])
xlabel('\theta'); ylabel('x\prime');
title('Red Sinogram')
figure, imagesc(Dtheta,xpg,Rg); colormap(hot); colorbar; caxis([-120000 80000])
xlabel('\theta'); ylabel('x\prime');
title('Green Sinogram')
figure, imagesc(Dtheta,xpb,Rb); colormap(hot); colorbar; caxis([-120000 80000])
xlabel('\theta'); ylabel('x\prime');
title('Blue Sinogram')
figure
imshow(recondImage)