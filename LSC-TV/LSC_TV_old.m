function E=ba_tv(X,D,lambda,beta)
[bands,pixels]=size(X)
dics=size(D,2);
k=0;
max_iter=100;
miu=0.01;
sigma=?????;
Z=zeros(bands,pixels);
J=Z;
P=Z;

H£¿£¿£¿£¿£¿£¿

R=H*P;
E=zeros(bands,pixels);
D1=E;
D2=J;
D3=P;
D4=R;
w=zeros(1,pixels);
while(1)
    %update Z_hat w W;
    for i=1:pixels
        w(1,i)=exp(-(norm(E(:,i))/sigma));
    end
    w_idx=?????  %choose w in the superpixel
    n=????%num of superpixels
    Zi
    sum=0
    for j=1:n
        sum=sum+w_idx(j)*Zi(j);
    end
    
    z_hat_idx=sum/norm(w_idx,1);
    Z_hat_idx=repmat(z_hat_idx,1,n)
    W=diag(w_idx);
    for k=1:10
        Z_temp=Z;
        Z=inv(D'D+2eye(bands))*(D'*(X-E-D1)+(J+D2)+(P+D3));
        J_temp=J;
        J=(Z_hat*w*w'+miu*(Z_temp-D2))*inv(W*W'+miu*eye(pixels));
        P_temp=P;
        P=inv(H'*H+eye(dics))*(Z_temp-D3+H'*(R+D4));
        R_temp=R;
        R=soft((H*P_temp-D4),lambda/miu);
        E_temp=E;
        E=soft_vector(X-D*Z_temp-D1,beta/miu);%soft_vector_threshold function
        
        %updata Lagrange multipliers
        D1=D1-(X-D*Z_temp-E_temp);
        D2=D2-(Z_temp-J_temp);
        D3=D3-(Z_temp-P_temp);
        D4=D4-(H*P_temp-R_temp);
        k=k+1;
    end
end
        


