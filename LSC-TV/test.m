anomaly=zeros(100,100);
E=E';
EE=reshape(E,100,100,102);
for i=1:100
    for j=1:100
        anomaly(i,j)=norm(reshape(EE(i,j,:),1,102),2);
    end   
end        
anomaly = (anomaly-min(anomaly(:)))/(max(anomaly(:))-min(anomaly(:)));       
imshow(anomaly);
colormap(jet);