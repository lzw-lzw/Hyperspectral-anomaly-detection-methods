function ret=soft_vector(U(:,i),t)
temp=max(norm(U(:,i))-t,0);
ret=temp/(temp+t);