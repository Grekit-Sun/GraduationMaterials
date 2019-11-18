function q = weightedguidedfilter(I, p, r, eps)

%I�� ����ͼ��
%p:  ���ָ�ͼ��
%r:  ���ڣ�
%eps: �����

%[hei, wid] = size(I);
%N = boxfilter(ones(hei,wid), r);

wxy = guidedfilter(I, I.*p, r, eps);
wxx = guidedfilter(I, I.*I, r, eps);
wy = guidedfilter(I, p, r, eps);
wx = guidedfilter(I, I, r, eps);

a = abs(wxy - wy.*wx) ./(abs(wxx - wx.*wx) + eps);
b = wy - a.*wx;

mean_a = guidedfilter(I, a, r, eps);
mean_b = guidedfilter(I, b, r, eps);

q = mean_a .* I + mean_b+eps;
end