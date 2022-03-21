load Pavia.mat
R=RXfunc(data);
RR=normalization(R);
imshow(RR);
colormap(jet);