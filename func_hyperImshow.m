function [rgb] = func_hyperImshow( hsi, RGBbands )
%% Hyperspectral Image color display
% Input:
%    hsi—the 3D hyperspectral dataset with the size of rows x cols x bands
%    RGBbands— the RGB bands to be displayed, with the format [R G B]
% Output:
%    rgb- the finual result with the RGB bands with the size of (rows x cols x 3)  
%% Main Function

hsi=double(hsi);
[rows, cols, bands] = size(hsi);

minVal =min(hsi(:));
maxVal=max(hsi(:));
normalizedData=hsi-minVal;

if(maxVal==minVal)
    normalizedData=zeros(size(hsi));
else
    normalizedData=normalizedData./(maxVal-minVal);
end

hsi=normalizedData;

[rows, cols, bands] = size(hsi);

if (nargin == 1)
    RGBbands = [bands round(bands/2) 1];
end

if (bands ==1)
    red = hsi(:,:);
    green = hsi(:,:);
    blue = hsi(:,:);
else
    red = hsi(:,:,RGBbands(1));
    green = hsi(:,:,RGBbands(2));
    blue = hsi(:,:,RGBbands(3));
end

rgb = zeros(size(hsi, 1), size(hsi, 2), 3);
rgb(:,:,1) = adapthisteq(red);      % Adaptive histogram equalization
rgb(:,:,2) = adapthisteq(green);
rgb(:,:,3) = adapthisteq(blue);
imshow(rgb); axis image;   % 保持图像的显示比例，其中axis为坐标轴的控制函数。
end
