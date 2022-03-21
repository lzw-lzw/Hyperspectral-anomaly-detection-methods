function [ROC,AUC]=ROC_AUC(S,gt)
% 2021.1.15 by addeng

[R,C]=size(S);
N=R*C;

[TPR,FPR,~] = roc(reshape(gt,N,1)',reshape(S,N,1)');%1*N

AUC=polyarea([0;sort(FPR','ascend');1;1],[0;sort(TPR','ascend');1;0]);%trapz?

% sAUC = num2str(AUC);
% algo = 'AUC:';
% tit = [algo sAUC];
% figure;semilogx(FPR,TPR,'-','LineWidth',3);title(tit);
% ylim([0,1]);

ROC=[TPR;FPR];

end









