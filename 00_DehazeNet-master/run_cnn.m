function [ dehaze ] = run_cnn( im )
%RUN_CNN Summary of this function goes here
%   Detailed explanation goes here
%https://blog.csdn.net/u012556077/article/details/53364438���˴���Ľ��ͳ�����
%https://blog.csdn.net/ametor/article/details/51274274
%https://blog.csdn.net/zonglingkui1591/article/details/79776555
r0 = 50;
eps = 10^-3; 
gray_I = rgb2gray(im);

load dehaze
haze=im-0.5;

%% Feature Extraction F1(������ȡF1)
f1=convolution(haze, weights_conv1, biases_conv1);
F1=[];
%�﷨�� A = reshape��A��m��n���� ���� A = reshape��A��[m,n]��; ���ǽ�A ���������г�m��n�С����� reshape�� ������ȡ���ݵģ�
%r=size(A,1)����䷵�ص�ʱ����A�������� c=size(A,2) ����䷵�ص�ʱ����A��������
f1temp=reshape(f1,size(f1,1)*size(f1,2),size(f1,3));
%for����1:2:10��ʾ������1��ʼ������Ϊ2����󲻳���10��������������1 3 5 7 9��
for step=1:4    %��1��ʼ����Ϊ4     %x(i,j,k)�ĺ����ǵ�k�����ĵ�i�е�j��Ԫ��;  x(:,:,1)���ʾ��1�����
    maxtemp=max(f1temp(:,(step*4-3):step*4),[],2); %�󲽳��е�t���ֵ  
    F1=[F1,maxtemp]; %#ok<AGROW>    %�����ֵ���ھ�����
end
F1=reshape(F1,size(f1,1),size(f1,2),size(F1,2));

%% Multi-scale Mapping F2 (��߶�ӳ��F2)
F2=zeros(size(F1,1),size(F1,2),48);
F2(:,:,1:16)=convolution(F1, weights_conv3x3, biases_conv3x3);
F2(:,:,17:32)=convolution(F1, weights_conv5x5, biases_conv5x5);
F2(:,:,33:48)=convolution(F1, weights_conv7x7, biases_conv7x7);

%% Local Extremum F3(��󵱵�F3)
F3=convMax(single(F2), 3);

%% Non-linear Regression F4(�����Իع�F4)
F4=min(max(convolution(F3, weights_ip, biases_ip),0),1);

%% Atmospheric light (������)
sortdata = sort(F4(:), 'ascend');
idx = round(0.01 * length(sortdata));   %������0.01
val = sortdata(idx); 
id_set = find(F4 <= val);
BrightPxls = gray_I(id_set);
iBright = BrightPxls >= max(BrightPxls);
id = id_set(iBright);
Itemp=reshape(im,size(im,1)*size(im,2),size(im,3));
A = mean(Itemp(id, :),1);
A=reshape(A,1,1,3);

%�����˲�����
%ָ��ͼ��gray_I��Ӧ���ǻҶ�/��ͨ��ͼ��
%��������ͼ��F4��ӦΪ�Ҷ�/��ͨ��ͼ��
%�ֲ����ڰ뾶��r0
%���򻯲�����eps
F4 = guidedfilter(gray_I, F4, r0, eps);
%F4 = weightedguidedfilter(gray_I, F4, r0, eps);   

J=bsxfun(@minus,im,A);  %����
J=bsxfun(@rdivide,J,F4); %���
J=bsxfun(@plus,J,A); %�ӷ�                        
%A=[1 2 3]
%B=[4; 5 ;6]
%bsxfun(@plus,A,B)
%A =
%     1     2     3
%B =
%     4
%     5
%     6
%ans =
%     5     6     7
%     6     7     8
%     7     8     9
dehaze=J;
end

