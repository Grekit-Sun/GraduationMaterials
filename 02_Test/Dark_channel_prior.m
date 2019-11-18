%clear workspace
clear;
clc;

%load test_picture �����ز�����Ƭ��
[fName pName]=uigetfile({'*.*'},'Open');

if fName
        original_im=imread([pName fName]); %����ͼƬ
    end
    %formatting im to float  ����ʽ��ͼƬ��

    original_im = double(original_im);
    % separate different channels - RGB���ֿ���ͬ��ͨ�� -  RGB��
R_channel = original_im(:, :, 1);
G_channel = original_im(:, :, 2);
B_channel = original_im(:, :, 3);

%create original_dark_channel image with same size��������С��ͬ��original_dark_channelͼ��
[row, column] = size(R_channel);  % row��ʾ������column��ʾ����
dark_channel_image = zeros(row,column);  %zeros����һ�������

%% ���RGBͨ�������ص���͵�ͨ��
%extract the minimum value of each point in RGB for dark_channel_image ��Ϊdark_channel_image��ȡRGB��ÿ�������Сֵ��
for i=1:row
    for j=1:column
        local_pixels =[R_channel(i,j), G_channel(i,j), B_channel(i,j)]; 
        dark_channel_image(i,j) = min(local_pixels );
    end
end

%image erode, minimum filtering��ͼ��ʴ����С���ˣ�
kernel = ones(30);  %ones(N) - ����N��N��������Ԫ�ؾ�Ϊ1�ľ��� ��kernel ���ģ�
final_im = imerode(dark_channel_image, kernel); %dark_channel_image��ͨ��ͼ�񣨴������ͼ�񣩣�kernel��30*30��ȫ1���󣨽ṹԪ�أ�
%��Сֵ�˲�
%final_im = ordfilt2(dark_channel_image,1,kernel);

%��ʴ��ԭ��https://blog.csdn.net/yarina/article/details/51354278
%��ֵͼ��ǰ������Ϊ1������Ϊ0.����ԭͼ������һ��ǰ�����壬��ô������һ���ṹԪ��ȥ��ʴԭͼ�Ĺ����������ģ�����ԭͼ���ÿһ�����أ�
%Ȼ���ýṹԪ�ص����ĵ��׼��ǰ���ڱ�����������أ�Ȼ��ȡ��ǰ�ṹԪ���������µ�ԭͼ��Ӧ�����ڵ��������ص���Сֵ���������Сֵ�滻��ǰ����ֵ��
%���ڶ�ֵͼ����Сֵ����0�����Ծ�����0�滻��������˺�ɫ�������Ӷ�Ҳ���Կ����������ǰ�ṹԪ�ظ����£�ȫ�����Ǳ�������ô�Ͳ����ԭͼ�����Ķ���
%��Ϊ����0.���ȫ������ǰ�����أ�Ҳ�����ԭͼ�����Ķ�����Ϊ����1.ֻ�нṹԪ��λ��ǰ�������Ե��ʱ�������ǵ������ڲŻ����0��1���ֲ�ͬ����
%��ֵ�����ʱ��ѵ�ǰ�����滻��0���б仯�ˡ���˸�ʴ��������Ч��������ǰ��������С��һȦһ��������ǰ��������һЩϸС�����Ӵ�������ṹԪ�ش�
%С��ȣ���Щ���Ӵ��ͻᱻ�Ͽ���


%transform dark_channel_imaege into Picture Format����dark_channel_imaegeת��ΪͼƬ��ʽ��
final_im = uint8(final_im);    %final_im�ǰ�ͨ��ͼ��
figure;set(gcf,'Position',get(0,'ScreenSize'));
%subplot(2,2,1), imshow(final_im);
%title("Dark Channel Prior");
%% ��������ͼ��İ�ͨ����ͼ��

%definne the size of filter_window�������˲������ڵĴ�С��
wid_x = 2;
wid_y = 2;

%augment image by pixels(value=128)������������ͼ��
augmented_im = ones(row+2*wid_x, column+2*wid_y, 3) * 128;
augmented_im(wid_x+1:row+wid_x, wid_y+1:column+wid_y, :) = original_im;

%find the value of Atmospheric light, which is the mean of top 0.1% value���ҵ��������ֵ���������0.1��ֵ��ƽ��ֵ��
%in dark_channel_prior����A��
%% ������AΪ��ͨ����������0.1%
%v_ac = reshape(dark_channel_image,1,column*row);
v_ac = reshape( double(final_im),1,column*row);
v_ac = sort(v_ac, 'descend');  %descend�����ţ�dim������
Ac = mean(v_ac(1:uint8(0.001*column*row)));
%%
%define and calculate minimum_matrix �����岢������С����
minimum = zeros(row+2*wid_x, column+2*wid_y);
for i= wid_x+1 : row+wid_x
    for j=wid_y+1: column+wid_y
        %extract local_window����ȡlocal_window��
        local_window = augmented_im(i-wid_x:i+wid_x, j-wid_y:j+wid_y, :);
        %separate RGB channels��������RGBͨ����
        local_r = local_window(:, :, 1);
        local_g = local_window(:, :, 2);
        local_b = local_window(:, :, 3);
        
        %normalize this current pixel in 3 channels�����˵�ǰ���ر�׼��Ϊ3��ͨ����
        channel_values = [ R_channel(i-wid_x,j-wid_y) / Ac, G_channel(i-wid_x,j-wid_y) / Ac, B_channel(i-wid_x,j-wid_y) / Ac ];
        %find the min values in 3 channels���ҵ�3��ͨ���е���Сֵ��
        minimum(i,j) = min(channel_values);
    end
end

%recover the augmented marix to previous size������ǿ����ָ�����ǰ�Ĵ�С��
%original_minimum = ones(row,column);
original_minimum = minimum(wid_x+1:wid_x+row, wid_y+1:wid_y+column);

%assign the local minimum for each point(Image Erode) ��Ϊÿ����ָ���ֲ���Сֵ��Image Erode����
kernel_erode = ones(2*wid_x+1,2*wid_y+1);
min_minimum = imerode(original_minimum, kernel_erode);

%define w as a parameter for adjustment ����w����Ϊ����������
w=0.95;
%define and calculate transmittance matrix ������ͼ���͸���ʾ���
pre_t = ones(row,column);
true_t = pre_t - w*min_minimum;  %�ָ�����
%�˲�
r = 50;
eps = 10^(-6);
%true_t = weightedguidedfilter(dark_channel_image,true_t,r,eps);
true_t = guidedfilter(dark_channel_image,true_t,r,eps);
true_w = guidedfilter_w(dark_channel_image,true_t,r,eps);
%subplot(2,2,2), imshow(uint8(true_t*255));  %true_t͸��ͼ
%subplot(2,2,3), imshow(uint8(true_t*255));  %true_t͸��ͼ
%title("Transmittance map");         

%set up a threshold for light transmittance������͸������ֵ��
K=55;
t0=0.1;
p=0.5;
for i=1:row
    for j=1:column
       true_t_1(i,j) = max(t0, true_t(i,j)); 
       true_t_2(i,j) = min((max(K /abs(original_im(i,j) - Ac),1))* max(t0, true_t(i,j)),1);
       true_t_3(i,j) = min((max(1+log10(K /abs(original_im(i,j) - Ac)),1))* max(t0, true_t(i,j)),1);
       true_t_4(i,j) = min((max((1+log10(K /abs(original_im(i,j) - Ac)))^p,1))* max(t0, true_w(i,j)),1);
       true_t_5(i,j) = min((max((1+log10(K /abs(original_im(i,j) - Ac)))^p,1))* max(t0, true_t(i,j)),1);
    end
end

%recover the final image by haze function��ͨ���������ָܻ�����ͼ��
final_image_1 = (original_im - Ac) ./ true_t_1 +Ac;
final_image_1 = uint8(final_image_1);

final_image_2 = (original_im - Ac) ./ true_t_2 +Ac;
final_image_2 = uint8(final_image_2);

final_image_3 = (original_im - Ac) ./ true_t_3 +Ac;
final_image_3 = uint8(final_image_3);

final_image_4 = (original_im - Ac) ./ true_t_4 +Ac;
final_image_4 = uint8(final_image_4);

final_image_5 = (original_im - Ac) ./ true_t_5 +Ac;
final_image_5 = uint8(final_image_5);

%show the result����ʾ�����
%figure;set(gcf,'Position',get(0,'ScreenSize'));
%subplot(2,2,3), imshow(uint8(original_im));
%title("Original image");

subplot(1,4,2),imshow(final_image_1);
title("After processing");
title("ԭ����");

%subplot(1,4,3),imshow(final_image_2);
%title("�ݲ����");

subplot(1,4,1),imshow(uint8(original_im));
title("ԭͼ");

subplot(1,4,3),imshow(final_image_5);
title("�����˲�")

subplot(1,4,4),imshow(final_image_4);
title("��Ȩ�����˲�")
%title("�ҵĸĽ�(p="+p+")");