function [data]=D2_to_3D(Y,R,C)
%% 2021.8.27 by addeng
%2D HSI to 3D



%%%%%%%%%img = reshape(Y.', 1, Newpixels, numBands); 
[B,N]=size(Y);


for i=1:B
    data(:,:,i)=reshape(Y(i,:),[R,C]);
end

% data=normalization(data);




% [H,W,B]=size(data);
% if col==1    
%     Y=reshape(data,[H*W,B])';%N按列排
% end
% 
% data_trans=zeros(W,H,B);
% if col==0
%     for i=1:B
%         data_trans(:,:,i)=data(:,:,i)';
%     end
%     Y=reshape(data_trans,[H*W,B])';%N按行排
% end

end
