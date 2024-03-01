function pSa = pSaFromPeriod(file,T)
% 读取pSa (g)
%
% 输入：
% file 谱加速度文件
% T 周期

temp = readmatrix(file,'Delimiter',',');
pSa = interp1(temp(1,:),temp(2,:),T);

end
