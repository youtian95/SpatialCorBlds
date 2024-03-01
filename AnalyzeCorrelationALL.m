function [CovFunMat,LogLikelihood,objCov] = AnalyzeCorrelationALL(SP_type, ...
    Sa_Scenario_filter, ...
    Capacity2D,EQDataStruct,ScenarioStruct, ...
    PartOfRSN)
% 分析所有建筑的相关性模型（同时分析）
%
% 输入:
% SP_type - 1~6 
% Sa_Scenario_filter - 过滤Sa小于Sa_Scenario_filter的结果
% Capacity2D - 结构能力的结构体，每个建筑为一个元胞
% EQDataStruct - 结构体数组, 1xN, 一个元素是一个台站的数据
% ScenarioStruct - 建筑场景地震分析结果，每个建筑为一个元胞
% PartOfRSN - RSN向量，仅使用此部分的数据进行拟合，可选
%
% 输出:
% CovFunMat - {N_bld x N_bld}, 每个ij元素为 i,j建筑间的相关性函数 pho(h)
% LogLikelihood - 最大似然函数对数值
% objCov - GPR_Stationary_SLFM对象

IDA_EDPtype = {'IDA_drift','IDA_accel','IDA_vel','IDA_Max_Drift', ...
    'RT','RC'};
Scenario_EDPtype = {'drift','accel','vel','max_drift', ...
    'RT','RC'};

% 计算epsilon观测值
SampleCell = {};
RSNCell  ={}; % 由于要筛选台站，每个建筑有观测值的台站不同，需要找出共同的台站
for i=1:numel(Capacity2D)
    [samples1,RSN1] = Plot_Scenario_CDF_lognormal(Capacity2D(i).T, ...
        Capacity2D(i).IMList,'empirical', ...
        Capacity2D(i).(IDA_EDPtype{SP_type})(:,:,1,1), ...
        ScenarioStruct{i}.(Scenario_EDPtype{SP_type})(:,1,1)', ...
        ScenarioStruct{i}.RSN', EQDataStruct, ...
        Sa_Scenario_filter, false);
    SampleCell{i} = samples1;
    RSNCell{i} = RSN1;
end
% 找共同RSN
Samples_intersec = [];
RSN_intersec = [];
for i=1:numel(EQDataStruct)
    bool = true;
    Samples_intersec_1col = zeros(numel(SampleCell),1);
    for i_bld = 1:numel(SampleCell)
        kk = find(RSNCell{i_bld}==EQDataStruct(i).RecordSequenceNumber,1);
        if isempty(kk)
            bool = false;
            break;
        else
            Samples_intersec_1col(i_bld) = SampleCell{i_bld}(kk);
        end
    end
    if bool
        RSN_intersec = [RSN_intersec,EQDataStruct(i).RecordSequenceNumber];
        Samples_intersec = [Samples_intersec,Samples_intersec_1col];
    end
end
assert(numel(RSN_intersec)>0);

RSN_complete = RSN_intersec;
Samples_complete = Samples_intersec;

% 仅适用部分数据
if nargin>5
    [row,col] = find(PartOfRSN'==RSN_intersec);
    assert(all(row'==(1:numel(PartOfRSN))));
    RSN_intersec = RSN_complete(col);
    Samples_intersec = Samples_complete(:,col);
end

% 相关性分析
[obj,covfun] = CrossCorrelation_MLE_Model(Samples_intersec,RSN_intersec,EQDataStruct,4);
% 顺便计算最大似然函数(用完整数据作为观测值)
RSNvec = [EQDataStruct.RecordSequenceNumber];
[row,~] = find((RSNvec==RSN_complete')');
lng = [EQDataStruct(row).StationLongitude];
lat = [EQDataStruct(row).StationLatitude];
[x,y] = LngLat2webMercator(lng,lat);
[x,y] = webMercator2xy(x,y);
LogLikelihood = obj.getLogLikelihood(Samples_complete,[x-x(1);y-y(1)]./1000);
objCov = obj;

CovFunMat = cell(numel(Capacity2D));
for i=1:numel(Capacity2D)
    for j=1:numel(Capacity2D)
        CovFunMat{i,j} = @(dist) GetCovDist(dist,i,j);
    end
end

    % 内部函数
    function Cov = GetCovDist(dist,i,j)
        Cov = covfun(dist);
        Cov = reshape(Cov(i,j,:),1,[]);
    end

end

