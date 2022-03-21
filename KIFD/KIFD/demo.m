clear,close all

%% Load data
addpath(genpath('./Data'));
addpath(genpath('./Kernel'));
load Pavia.mat
data1=data;
map=groundtruth;
% [data1,map]=ReadData(num2str(2)); 
row = size(data1,1);
col = size(data1,2);
data2 = NormalizeData(data1);
tic
%% Set default parameters
data_kpca = kpca(data2, 10000, 300, 'Gaussian',1); 
data = NormalizeData(data_kpca);
data = ToVector(data);
tree_size = floor(3 * row * col /100); 
tree_num = 1000;
%% Run global iForest
s = iforest(data, tree_num, tree_size); % 1 hyperspectral data  2 number of isolation  3 trees subsample size
%% Run local iForest iteratively
img = reshape(s, row, col);
stop_flag = 0;
index = [];
num = 1;
r0 = img;
lev =  (r0);   % 
while stop_flag == 0
    [r1, flag, s1, index1] = Local_iforest(r0, data, s, index, lev); 
    r0 = r1;
    s = s1;
    index = index1;
    stop_flag = flag;
    num = num + 1;
    if num > 5 
        break;
    end
end
img = zeros(row,col);
img(index1) = 1;
index = (1:row*col)';
index(index1, :) = [];
Data_d = data(:, :);
Data_d(index1,:) = [];
s_d = iforest(Data_d, tree_num, tree_size); 
r1(index) = s_d;
r2 = 10.^r1;
%% Evaluate the results
toc
r0 = mat2gray(r2); 
[PD0,PF0] = roc(map(:), r0(:));
AUC =  -sum((PF0(1:end-1)-PF0(2:end)).*(PD0(2:end)+PD0(1:end-1))/2);
r0_rgb = ImGray2Pseudocolor(r0, 'bone', 255); % bone
figure, imshow(r0_rgb);
% imwrite(r0_rgb,'./KIFD.jpg');

