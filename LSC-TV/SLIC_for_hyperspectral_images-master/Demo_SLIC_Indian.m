%% Demo_SLIC_Indian: Demo for the hyperspectral SLIC segmentation on
%% the AVIRIS Indian Pines scene
%% 
clear all
close all
clc

n_pc = 4;

load Pavia.mat
img = imread('bee.jpg');
img=img(:,1:425,:);
[nl, ns, nb] = size(img); 
PC = fPCA_2D_SpecificV1(reshape(img, nl * ns, nb),1,1,0);
PC = PC(:,1:n_pc);
HIM = reshape(PC,100,100,n_pc);
clear data
x = PC';
clear data PC;

% reshape the data into a vector
input_img = zeros(1, nl * ns * n_pc);

startpos = 1;
for i = 1 : nl % lines
    for j = 1 : ns % columes
        input_img(startpos : startpos + n_pc - 1) = HIM(i, j, :); % bands
        startpos = startpos + n_pc;
    end
end

%% SLIC Segmentation
numSuperpixels = 400;  % the desired number of superpixels
compactness = 0.1; % compactness2 = 1-compactness, the clustering is according to: compactness*dxy+compactness2*dspectral
dist_type = 2; % distance type - 1:Euclidean£»2£ºSAD; 3:SID; 4:SAD-SID
seg_all = 1; % 1: all the pixles participate in the clustering£¬ 2: some pixels would not
% labels: segmentation results
% numlabels: the final number of superpixels
% seedx: the x indexing of seeds
% seedy: the y indexing of seeds
[labels, numlabels, seedx, seedy] = hybridseg(input_img, nl, ns, n_pc, numSuperpixels, compactness, dist_type, seg_all);%numlabels is the same as number of superpixels
clear input_img;