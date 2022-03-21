%function [R_2D]=RXfunc_3D(data,GT)
function [R_2D,AUC]=RXfunc_3D(data,GT,delta)
%input 3D HSI after normalization
%2020 11 24 by addeng

if (nargin<3)
    delta=0;
end

[H,W,B]=size(data);
N=H*W;

Y=D3_to_2D(data,1);
%[B,n]=size(x);

m=mean(Y,2);
data=Y-repmat(m,1,N);
% c=zeros(B);
% for i=1:n
%     c=c+(data(:,i))*(data(:,i))';%B*B
% end
c=data*data';
c=c/N;%这个和cov函数里的协方差求法不太一样


c = c+delta*eye(size(c));

%R=data'*inv(c+1e-5*eye(size(c)))*data;
% R=zeros(n,1);
% for i=1:n
%     R(i)=data(:,i)'*inv(c*n/(n+1)+data(:,i)*data(:,i)'/(n+1))*data(:,i);
% end
if N<100000  
    R=data'*inv(c)*data;%这个没有求逆的c效果反而更好
    R_2D=reshape(diag(R),[H,W]);
    R_2D=normalization(R_2D);
else
    invc=inv(c);
    for ii=1:N
        R(ii)=data(:,ii)'*invc*data(:,ii);
    end
    R_2D=reshape(R,[H,W]);
    R_2D=normalization(R_2D);
end


[ROC,AUC]=ROC_AUC(R_2D,GT);

TPR=ROC(1,:);
FPR=ROC(2,:);


sAUC = num2str(AUC);
algo = 'AUC:';
tit = [algo sAUC];
figure;
semilogx(FPR,TPR,'-','LineWidth',3);title(tit);
ylim([0,1]);

end




