function D=dictionary_func(X,k,p)
[idx,c]=kmeans(X,k);
D=[];
for i=1:k
   idxi=find(idx==i);
   temp=X(idxi,:);
   len=length(idxi);
   if (len<p)
       continue
   end
   mean_vec=mean(temp,1);
   conv_matrix=cov(temp);
   for j=1:len
       pset=zeros(1,len);
       xj=temp(j,:);
       pd=(xj-mean_vec)*pinv(conv_matrix)*(xj-mean_vec)';
       pset(j)=pd;    
   end
   [B,I]=sort(pset);
   D_temp=temp(I(1:p),:);
   D=[D;D_temp];
    
end
D=D';
