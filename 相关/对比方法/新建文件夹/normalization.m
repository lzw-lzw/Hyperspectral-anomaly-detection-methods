function [s_new]=normalization(s,b)
%% 2020.11.16 by addeng
%3dimensional
%for all band, b=0
%for each band, b=1
if (nargin<2)
    b=0;
end

if b==0
    max_s=max(max(s(:)));
    min_s=min(min(s(:)));
    s_new=(s-min_s)./(max_s-min_s);
end
    
if b==1
    bands=size(s,3);
    for i=1:bands
        max_s=max(max(s(:,:,i)));
        min_s=min(min(s(:,:,i)));
        s_new(:,:,i)=(s(:,:,i)-min_s)./(max_s-min_s);
    end
end
end



















