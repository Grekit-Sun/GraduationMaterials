clc;
clear;
close all;

haze=imread('data/rc.png');
haze=double(haze)./255;
dehaze=run_cnn(haze);
dehaze_zyc=run_cnn_zyc(haze);
% subplot(m,n,p),m��ʾ��ͼ�ų�m�У�n��ʾͼ�ų�n�У�p=[a,b,c,..]������
figure;set(gcf,'Position',get(0,'ScreenSize'));
subplot(1,2,1);
imshow(haze),title('����ͼƬ');
subplot(1,2,2);
imshow(dehaze),title('ȥ��ͼƬ');
%subplot(1,3,3);
%imshow(dehaze_zyc),title('���ϳ��˲�');
