function [obj,covfun] = CrossCorrelation_MLE_Model( ...
    samples,RSN,EQDataStruct, ...
    KernelFunction)
% 根据最大似然估计计算互相关系数
%
% 输入：
% samples - 场景地震的 (log(EDP)-lgMean)/lgSigma 的观测值, 矩阵，行数为输出维度，
%       列数为场地数量 numel(RSN)
% RSN - 对应的RSN编号, 行向量
% EQDataStruct - 所有地震波的元数据结构体
% KernelFunction - 1: 'squaredexponential'; 2: 'exponential'; 3:
%       'exponential_plus_constant'; 4: 'RationalQuadratic'; 
%       5: RationalQuadratic_plus_constant
%
% 输出：
% obj - GPR_Stationary_SLFM类
% covfun - 协方差函数句柄

RSNvec = [EQDataStruct.RecordSequenceNumber];
[row,~] = find((RSNvec==RSN')');
lng = [EQDataStruct(row).StationLongitude];
lat = [EQDataStruct(row).StationLatitude];
[x,y] = LngLat2webMercator(lng,lat);
[x,y] = webMercator2xy(x,y);

obj = GPR_Stationary_SLFM([x-x(1);y-y(1)]./1000,samples'); % m化为km
obj.KernelType = KernelFunction;
% 初始值
Do = size(samples,1);
Q = obj.Q;
N_para = obj.N_HyperPara(obj.KernelType);
A0 = eye(Do,Q);
Kernal0 = 0.1*ones(Q,N_para);
for i_Do=1:Do
    obj1 = GPR_Stationary_SLFM([x-x(1);y-y(1)]./1000,samples(i_Do,:)');
    obj1.KernelType = KernelFunction;
    obj1.Q = 1;
    obj1.Optimize();
    A0(i_Do,i_Do) = obj1.A;
    Kernal0(i_Do,:) = obj1.HyperPara2;
end
[exitflag,exitinfo] = obj.Optimize(A0,Kernal0);
if (exitflag==0) || (exitflag==-1)
    disp(exitinfo);
elseif exitflag<-1
    disp(exitinfo);
    error('Error: 迭代失败！');
end
disp('HyperPara2 (Q x [l,alpha]):');
disp(obj.HyperPara2);
disp('A:');
disp(obj.A);

covfun = @(x) GetCovariance(obj,x);

end

