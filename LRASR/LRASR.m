clear all;clc;
load Pavia.mat
[size_image.Length,size_image.Width,size_image.Band]=size(data);
data=reshape(data,size_image.Length*size_image.Width,size_image.Band);

D=dictionary_func(data,15,20);
data2=data';
[S,E,J] = LADMAP_LRASR(data2,D,0.1,0.1);
anomaly=zeros(100,100);
E=E';
EE=reshape(E,100,100,102)
for i=1:100
    for j=1:100
        anomaly(i,j)=norm(reshape(EE(i,j,:),1,102),2);
    end   
end  
      
anomaly = (anomaly-min(anomaly(:)))/(max(anomaly(:))-min(anomaly(:)));       
imshow(anomaly);
colormap(jet);
[TPR_CRD,FPR_CRD,~] = roc(reshape(groundtruth,10000,1)',reshape(anomaly,10000,1)');
AUC_CRD = polyarea([0;sort(FPR_CRD','ascend');1;1],[0;sort(TPR_CRD','ascend');1;0]);
sAUC = num2str(AUC_CRD);
algo = 'CRD AUC:';
tit = [algo sAUC];
figure;semilogx(FPR_CRD,TPR_CRD,'-','LineWidth',3);title(tit);
ylim([0,1]);


