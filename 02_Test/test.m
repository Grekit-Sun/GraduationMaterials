clc;
clear;
close all;

%% ��һ��ͼ��İ�ͨ��ͼ�񣬴��ڴ�СΪ15*15
imageRGB = imread('data/mountain.jpg');
imageRGB = double(imageRGB);
imageRGB = imageRGB./255;
dark = darkChannel(imageRGB);

%% ѡȡ��ͨ����������0.1%���أ��Ӷ�ȡ�ô�����
[m, n, ~] = size(imageRGB);
imsize = m*n;
numpx = floor(imsize/1000);
JDarkVec = reshape(dark,imsize,1);
ImVec = reshape(imageRGB,imsize,3);

[JDarkVec, indices] = sort(JDarkVec);
indices = indices(imsize-numpx+1:end);
atmSum = zeros(1,3);
for ind = 1:numpx
    atmSum = atmSum + ImVec(indices(ind),:);
end
atmospheric = atmSum / numpx;

%% ���͸���ʣ���ͨ��omega������ѡ����һ���̶���������������ʵ��
omega = 0.95;
im = zeros(size(imageRGB));

for ind = 1:3
    im(:,:,ind) = imageRGB(:,:,ind)./atmospheric(ind);
end

dark_2 = darkChannel(im);
t = 1 - omega*dark_2;

%% ͨ�������˲�����ø�Ϊ��ϸ��͸��ͼ 
r = 60;
eps = 10^-6;
refined_t = weightedguidedfilter(imageRGB,t,r,eps);
%refined_t = guidedfilter_color(imageRGB,t,r,eps);

refinedRadiance = getRadiance(atmospheric,imageRGB,refined_t);