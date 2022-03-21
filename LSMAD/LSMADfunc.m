function [B,S] = LSMADfunc(X,r,k,epsilon,iter)
B=X;
[num_pixel,num_band]=size(X);
S=zeros(num_pixel,num_band);
t=0;
A1=randn(num_band,r);
while(t<=iter)
    Y1=(X-S)*A1;
    A2=Y1;
    Y2=(X-S)'*A2;
    if(rank(A2'*Y1)<r)
        r=rank(A2'*Y1);
        continue;       
    end
    P=X-B;
    B=Y1*inv(A2'*Y1)*Y2';
    
    [~,idx] = sort(abs(P(:)),'descend');
    S(idx(1:k)) = P(idx(1:k));
    
    con=trace((X-B-S)'*(X-B-S))/trace(X'*X);
    if(con<epsilon)
        break;
    end
    t=t+1
end

