function [Y]=D3_to_2D(data,col)
%% 2021.1.13 by addeng
%3D HSI to 2D
%col, col=1
%row, col=0(default)

if (nargin<2)
    col=0;
end

[H,W,B]=size(data);
if col==1    
    Y=reshape(data,[H*W,B])';%N按列排
end

data_trans=zeros(W,H,B);
if col==0
    for i=1:B
        data_trans(:,:,i)=data(:,:,i)';
    end
    Y=reshape(data_trans,[H*W,B])';%N按行排
end

end


