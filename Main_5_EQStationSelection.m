%% 台站选择方法对比

addpath('3rd Party\PEER record tool');
addpath('3rd Party\WebMercator2LongLat');
addpath('3rd Party\Gaussian Process Regression');
addpath('3rd Party\Convert Symmetrical Matrix to Semi Positive');
load('Capacity2D.mat');
load("ScenarioAnalysis_Northridge19940117.mat");

% 台站数量
if ~exist('N_EQ')
    N_EQ = 20;
end

%% 读取地震动数据
EQName = 'Northridge';
if exist('EQDataStruct_Northridge19940117.mat','file')
    load('EQDataStruct_Northridge19940117.mat');
else
    MetaDataFile = ['PEER NGA Data\NGA_West2_flatfiles\', ...
       'Updated_NGA_West2_Flatfile_RotD50_d050_public_version.xlsx'];
    EQDate = '19940117';
    EQTimeSeriesDir = { ...
        'PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup0-40', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup40-200'};
    EQDataStruct = Read1ScenarioEQData(MetaDataFile, EQName, EQDate, EQTimeSeriesDir);
end

% 绘图
RSN_Filter = [EQDataStruct.AccHistoryFileExist] ...
    & ([EQDataStruct.PGA_g_]>=0.05); % PGA大于0.05g
Plot_StationMap(EQDataStruct, EQName, RSN_Filter);

%% 筛选方法对比
% 距离矩阵
RSNAll = [EQDataStruct.RecordSequenceNumber];
RSNAll = RSNAll(RSN_Filter);
DistMat_vec = Station_Dist(reshape(repmat(RSNAll',1,numel(RSNAll)),1,[]), ...
    reshape(repmat(RSNAll,numel(RSNAll),1),1,[]),EQDataStruct);
DistMat = reshape(DistMat_vec,numel(RSNAll),numel(RSNAll));
DistMat = (DistMat+DistMat')./2;

% 方法1：总距离最小
RSN1_ind = FindStationSet_SumDist(DistMat,N_EQ,'smallest');
RSN1 = RSNAll(RSN1_ind);

% 方法2：总距离最大
RSN2_ind = FindStationSet_SumDist(DistMat,N_EQ,'greatest');
RSN2 = RSNAll(RSN2_ind);

% 方法3：距离的分布尽量均匀
RSN3_ind = FindStationSet_Uniform(DistMat,N_EQ);
RSN3 = RSNAll(RSN3_ind);


%% 台站选择绘图
Plot_StationMap(EQDataStruct, EQName, RSN_Filter, [RSN1;RSN2;RSN3]);

%% 相关性分析
warning('off','all');
SP_type = 4; % 6-'RC',5-'RT',4-'max_drift'
switch SP_type
    case 6
        S = load('CovFunMat_RC.mat'); %包含CovFunMat和LogLikelihood
    case 5
        S = load('CovFunMat_RT.mat');
    case 4
        S = load('CovFunMat_IDR.mat');
end
% 所有数据
CovFunMat0 = S.CovFunMat; 
LogLikelihood0 = S.LogLikelihood; 
Sa_Range = [0,inf];
% 集合RSN1：总距离最小
[CovFunMat1,LogLikelihood1] = AnalyzeCorrelationALL(SP_type,Sa_Range, ...
    Capacity2D,EQDataStruct,ScenarioStruct,RSN1);
% 集合RSN2：总距离最大
[CovFunMat2,LogLikelihood2] = AnalyzeCorrelationALL(SP_type,Sa_Range, ...
    Capacity2D,EQDataStruct,ScenarioStruct,RSN2);
% 集合RSN3：距离的分布尽量均匀
[CovFunMat3,LogLikelihood3] = AnalyzeCorrelationALL(SP_type,Sa_Range, ...
    Capacity2D,EQDataStruct,ScenarioStruct,RSN3);

%% 绘图：相关性
if ~exist('CovFunMat1','var')
    load(['CovFunMat_Partial',num2str(N_EQ),'_IDR.mat']);
end
Plot_rho_tile({CovFunMat0,CovFunMat1,CovFunMat2,CovFunMat3});
disp('LogLikelihood:');
disp([LogLikelihood0,LogLikelihood1,LogLikelihood2,LogLikelihood3]);

