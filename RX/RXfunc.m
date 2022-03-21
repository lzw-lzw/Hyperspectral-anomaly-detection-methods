function [R]=RXfunc(x)
%input 3D HSI

[H,W,B]=size(x);
n=H*W;
x=normalization(x);
x=reshape(x,[n,B])';%B,n

m=mean(x,2);
data=x-repmat(m,1,n);

c=data*data';
c=c/n;

R=data'*inv(c)*data;%加个delta可以改善
R=reshape(diag(R),[H,W]);


end




