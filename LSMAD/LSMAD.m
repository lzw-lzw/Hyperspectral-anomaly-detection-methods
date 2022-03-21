load Pavia.mat
size(data)
[length,width,band]=size(data);
data=reshape(data,length*width,band);
[B,S] = LSMADfunc(data,1,0.5*length*width,0.2,30);

SS=reshape(S,100,100,102);
anomaly=zeros(100,100);
for i=1:100
    for j=1:100
        anomaly(i,j)=norm(reshape(SS(i,j,:),1,102),2);
    end   
end        
anomaly = (anomaly-min(anomaly(:)))/(max(anomaly(:))-min(anomaly(:)));       
imshow(anomaly);

[TPR_CRD,FPR_CRD,~] = roc(reshape(groundtruth,10000,1)',reshape(anomaly,10000,1)');
AUC_CRD = polyarea([0;sort(FPR_CRD','ascend');1;1],[0;sort(TPR_CRD','ascend');1;0]);
sAUC = num2str(AUC_CRD);
algo = 'CRD AUC:';
tit = [algo sAUC];
figure;semilogx(FPR_CRD,TPR_CRD,'-','LineWidth',3);title(tit);
ylim([0,1]);