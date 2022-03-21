function [E] = solve_l1l2(W,lambda)
n = size(W,2);
E = W;
for i=1:n
    E(:,i) = solve_l2(W(:,i),lambda);
end