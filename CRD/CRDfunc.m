%%
%%collaborative representation anomaly detection
%%d_CRD is the detection result
%%image is the input M*N*B cube
%%size_InnerWindow and size_Outwindow are the sizes of CRD windows
%%2015.3.25    niuyubin

function d_CRD_show = CRDfunc(image,groundtruth,InnerWindowSize,OuterWindowSize,lambda)
% addpath(genpath('E:\实验室\目标探测\datasets'));
% addpath(genpath('E:\实验室\目标探测\code\My_Lib'))
% load('Hyperion.mat');   % 0.99296
% load('urban.mat');
% load('avris.mat');
% load('abu_beach-44.mat');
if (nargin<5)
    lambda=10^-6;
end
% image = double(data);
% InnerWindowSize = 11;
% OuterWindowSize = 21;
% OuterWindowSize = 1;
% InnerWindowSize = 1;

[size_image.Length,size_image.Width,size_image.Band]=size(image);
num_pixel = size_image.Length*size_image.Width;

% image=double(image);
large_image=repmat(image,3,3);
temp_outer=(OuterWindowSize-1)/2;
large_image=large_image(size_image.Length-temp_outer+1:2*size_image.Length+temp_outer,size_image.Width-temp_outer+1:2*size_image.Width+temp_outer,:);

Background_Window=ones(OuterWindowSize,OuterWindowSize);
Background_Window((OuterWindowSize-InnerWindowSize)/2+1:(OuterWindowSize+InnerWindowSize)/2,(OuterWindowSize-InnerWindowSize)/2+1:(OuterWindowSize+InnerWindowSize)/2)=0;
ID_Window=find(Background_Window==1);
N_dictionary=length(ID_Window);
d_CRD=zeros(size_image.Length,size_image.Width);
%lambda=10^-6;
for i=1:size_image.Length
    for j=1:size_image.Width
        Background_Area=large_image(i:i+OuterWindowSize-1,j:j+OuterWindowSize-1,:);
        Background=reshape(Background_Area,OuterWindowSize*OuterWindowSize,size_image.Band);
        dictionary_local=Background(ID_Window,:)';
        PUT=reshape(image(i,j,:),size_image.Band,1);
        X_S=[dictionary_local;ones(1,N_dictionary)];
%         X_S=dictionary_local;%%测试STO
        PUT_hat=[PUT;1];
%         PUT_hat=PUT;%%测试STO
        T_y=diag(sqrt(sum((dictionary_local-repmat(PUT,1,N_dictionary)).^2)));
%         T_y=eye(N_dictionary);  %%测试，使得T_y无作用
        alpha_hat=(X_S'*X_S+lambda*T_y'*T_y)\X_S'*PUT_hat;
        d_CRD(i,j)=norm(PUT-dictionary_local*alpha_hat);
    end
end


d_CRD_show = (d_CRD-min(d_CRD(:)))/(max(d_CRD(:))-min(d_CRD(:)));
figure;
imshow(d_CRD_show);
colormap(jet);   %% colormap(jet)  //   imagesc(figure;d_RBRSE_local_show)

[TPR_CRD,FPR_CRD,~] = roc(reshape(groundtruth,num_pixel,1)',reshape(d_CRD,num_pixel,1)');
AUC_CRD = polyarea([0;sort(FPR_CRD','ascend');1;1],[0;sort(TPR_CRD','ascend');1;0]);
sAUC = num2str(AUC_CRD);
algo = 'CRD AUC:';
tit = [algo sAUC];
figure;semilogx(FPR_CRD,TPR_CRD,'-','LineWidth',3);title(tit);
ylim([0,1]);
