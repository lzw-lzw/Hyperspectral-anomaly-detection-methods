clear all;clc;
load Pavia.mat
[size_image.Length,size_image.Width,size_image.Band]=size(data);
d_CRD_show=zeros(size_image.Length,size_image.Width);
d_CRD_show=CRDfunc(data,groundtruth,3,11,1e-6)
