function [E] = ba_tv(X,D,im_size, display,labels,numlabels)

[l, n] = size(X);%num of bands and pixels
m=size(D,2);%num of bands
% m = size(B, 2);
% c = size(A, 2);

% rho = 1.2;
% mu = 1e-3;% initial mu and rho, can be tuned
% mu_bar = 1e10;
% initialization
% X0 = 0;
atx_D=D'*D;

% atx_A = 2*(A'*A);
% atx_Y = 2*(A'*Y);
% 
% atx_B = 2*(B'*B);
% atx_Y1 = 2*(B'*Y);

%%
% build handlers and necessary stuff
% horizontal difference operators
FDh = zeros(im_size);
FDh(1,1) = -1;
FDh(1,end) = 1;
FDh = fft2(FDh);
FDhH = conj(FDh);

% vertical difference operator
FDv = zeros(im_size);
FDv(1,1) = -1;
FDv(end,1) = 1;
FDv = fft2(FDv);
FDvH = conj(FDv);

IL = 1./( FDhH.* FDh + FDvH.* FDv + 1);

Dh = @(x) real(ifft2(fft2(x).*FDh));
DhH = @(x) real(ifft2(fft2(x).*FDhH));

Dv = @(x) real(ifft2(fft2(x).*FDv));
DvH = @(x) real(ifft2(fft2(x).*FDvH));

%%
%---------------------------------------------
%  Initializations
%---------------------------------------------

k=0;
maxIter =30;
mu=0.01;
lambda=0.001;
% beta=0.01;
beta=0.005;
sigma=10;
E=zeros(l,n);
Z=zeros(m,n);
J=Z;
P=Z;
D1=E;
D2=J;
D3=P;


U_im = reshape(Z',im_size(1), im_size(2),m);


R=cell(m,2);
D4=cell(m,2);
for kk=1:m
    R{kk}{1}=Dh(U_im(:,:,kk));
    R{kk}{2}=Dv(U_im(:,:,kk));
    D4{kk}{1}=zeros(im_size);
    D4{kk}{2}=zeros(im_size);
end    

clear U_im;

%%
%---------------------------------------------
%  AL iterations - main body
%---------------------------------------------
tol = sqrt(n)*1e-5;
iter = 1;
res = inf;
% while (iter <= maxIter) && (sum(abs(res)) > tol)
while (iter <= maxIter)
    iter
    if((mod(iter,10)==0)||iter==1)
        w=exp(-(vecnorm(E)/sigma));
        W=diag(w);
        for i=1:numlabels
            idx=find(labels==i);
            len=length(idx);
            Xi=X(:,idx);
            Zi=D\Xi;
            wi=w(idx);
            
            sumzw=0;
            for j=1:len
                sumzw=sumzw+wi(1,j)*Zi(:,j);
            end
            zi_hat=sumzw/norm(wi,1);
%             Z_hat(:,idx)=zi_hat;   
            Z_hat(:,idx)=repmat(zi_hat,1,len);
        end 
        atx_W=W*W';
        fprintf('update w Z');
    end
    % solve the quadratic step

    Z=(atx_D+2*eye(m))\(D'*(X-E-D1)+(J+D2)+(P+D3));
    J=(Z_hat*atx_W+mu*(Z-D2))*inv(atx_W+mu*eye(n));
    nu_aux =Z-D3;

    nu_aux_im = reshape(nu_aux',im_size(1), im_size(2),m);
    
    for k = 1:m
        
        
        V1_im(:,:,k) = real(ifft2(IL.*fft2(DhH(R{k}{1}-D4{k}{1}) ...
            +  DvH(R{k}{2}-D4{k}{2}) +  nu_aux_im(:,:,k))));

        aux_h = Dh(V1_im(:,:,k));
        aux_v = Dv(V1_im(:,:,k));

        R{k}{1} = soft(aux_h + D4{k}{1}, lambda/mu);   %horizontal
        R{k}{2} = soft(aux_v + D4{k}{2}, lambda/mu);   %vertical

        D4{k}{1} =  D4{k}{1} + (aux_h - R{k}{1});
        D4{k}{2} =  D4{k}{2} + (aux_v - R{k}{2});
    end
    % convert V1 to matrix format

    P = reshape(V1_im, prod(im_size),m)';            
        
    % V3
    


    E=solve_l1l2(X-D*Z-D1,beta/mu);
    % update Lagrange multipliers    
    
    D1=D1-(X-D*Z-E);
    D2=D2-(Z-J);
    D3=D3-(Z-P);
    
    
    

    
    % compute residuals
%     if mod(iter,10) == 1
%     st = [];
%     res(1)=norm(J-Z,'fro');
%     st = strcat(st,sprintf('  res(1) = %2.6f',res(1)));
%     res(2)=norm(P-Z,'fro');
%     st = strcat(st,sprintf('  res(2) = %2.6f',res(2)));
%     res(3)=norm(X-D*Z-E,'fro');
%     st = strcat(st,sprintf('  res(3) = %2.6f',res(3)));
% %     res(4)=norm(Z-R,'fro');
% %     st = strcat(st,sprintf('  res(4) = %2.6f',res(4)));
%     if display
%         fprintf(strcat(sprintf('iter = %i -',iter),st,'\n'));
    iter = iter + 1; 
end
end

% function [E] = solve_l1l2(W,lambda)
% n = size(W,2);
% E = W;
% for i=1:n
%     E(:,i) = solve_l2(W(:,i),lambda);
% end
% 
% function [x] = solve_l2(w,lambda)
% % min lambda |x|_2 + |x-w|_2^2
% nw = norm(w);
% if nw>lambda
%     x = (nw-lambda)*w/nw;
% else
%     x = zeros(length(w),1);
% end