function d_LRX_show = LRX(image,groundtruth,InnerWindowSize,OuterWindowSize,delta)
% close all;
% clear;
% clc;
% 
% addpath(genpath('E:\实验室\目标探测\datasets'));
% addpath(genpath('E:\实验室\目标探测\code\My_Lib'))
% % load('avris.mat');
% % load('Hyperion.mat');  %0.99953
% load('abu_beach-44.mat');

% image = double(data);
% InnerWindowSize = 5;
% OuterWindowSize = 15;
image = (image-min(image(:)))/(max(image(:))-min(image(:)));
[Length_image,Width_image,Bands_image]=size(image);
num_pixel = Length_image*Width_image;
image_transform=double(reshape(image,Length_image*Width_image,Bands_image));%n*B
% [~,pca_image,pca_latent]=pca(image_transform);
% pca_latent=pca_latent/sum(pca_latent);
% for i=Bands_image:-1:1
%     pca_latent(i)=sum(pca_latent(1:i));
% end
% pca_num=max(find(pca_latent<0.999));%%降维因为协方差矩阵不可逆（或者说太多趋近于0的特征根）
% pca_image=pca_image(:,1:pca_num);

d_LRX=zeros(Length_image,Width_image);

% pca_image=reshape(pca_image,Length_image,Width_image,pca_num);
temp_outer=(OuterWindowSize-1)/2;
large_image=repmat(image,3,3);%这种拓展方式，不能保证边缘的关联性吧，镜像是否更有用呢
large_image=large_image(Length_image-temp_outer+1:2*Length_image+temp_outer,Width_image-temp_outer+1:2*Width_image+temp_outer,:);
Background_Window=ones(OuterWindowSize,OuterWindowSize);
Background_Window((OuterWindowSize-InnerWindowSize)/2+1:(OuterWindowSize+InnerWindowSize)/2,(OuterWindowSize-InnerWindowSize)/2+1:(OuterWindowSize+InnerWindowSize)/2)=0;%内窗为0，窗间为1
ID_Window=find(Background_Window==1);%列向量，如[1,2,3,4,6,7,8,9]'


for i=1:Length_image
    for j=1:Width_image
        Background_Area=large_image(i:i+OuterWindowSize-1,j:j+OuterWindowSize-1,:);
        Background=reshape(Background_Area,OuterWindowSize*OuterWindowSize,Bands_image);
        Background=Background(ID_Window,:);%窗间像素点
        mean_Background=mean(Background);
%         cov_Background=cov(Background);
        cov_Background = Background'*Background;%没有/n
%         d_LRX(i,j)=(reshape(image(i,j,:),1,Bands_image)-mean_Background)/cov_Background*(reshape(image(i,j,:),1,Bands_image)-mean_Background)';


        %delta=1e-5;%regularizaton parameter
        BInv = inv(cov_Background+delta*eye(size(cov_Background)));
        
        d_LRX(i,j)=(reshape(image(i,j,:),1,Bands_image)-mean_Background)*BInv*(reshape(image(i,j,:),1,Bands_image)-mean_Background)';
   
    end
end
d_LRX=reshape(d_LRX,Length_image,Width_image);
% d_LRX_show=d_LRX;
d_LRX_show=(d_LRX-min(d_LRX(:)))/(max(d_LRX(:))-min(d_LRX(:)));

% figure;
% imshow(d_LRX_show);
% colormap(jet);   %% colormap(jet)  //   imagesc(figure;d_RBRSE_local_show)
% 
% [TPR_LRX,FPR_LRX,~] = roc(reshape(groundtruth,num_pixel,1)',reshape(d_LRX_show,num_pixel,1)');
% AUC_LRX = polyarea([0;sort(FPR_LRX','ascend');1;1],[0;sort(TPR_LRX','ascend');1;0]);
% 
% sAUC = num2str(AUC_LRX);
% algo = 'LRX AUC:';
% tit = [algo sAUC];
% figure;semilogx(FPR_LRX,TPR_LRX,'-','LineWidth',3);title(tit);
% ylim([0,1]);