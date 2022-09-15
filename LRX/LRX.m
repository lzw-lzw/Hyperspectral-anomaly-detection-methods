load Pavia.mat
d_LRX_show = LRXfunc(data,groundtruth,3,5,1e-5);
imshow(d_LRX_show);
colormap(jet);