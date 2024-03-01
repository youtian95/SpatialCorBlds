%% 区域地震损失分析
if 0
    EQName = 'Northridge19940117';
else
    EQName = 'Chi-Chi19990920';
end
addpath('3rd Party\Gaussian Process Regression');
addpath('3rd Party\WebMercator2LongLat');
addpath('3rd Party\Convert Symmetrical Matrix to Semi Positive');
load("Capacity2D.mat");
load(['EQDataStruct_',EQName,'.mat']);
load(['ScenarioAnalysis_',EQName,'.mat']);

%% 建筑分布
density = 0.1; % km
BldDistType = "Same A buildings";
switch BldDistType
    case "Same A buildings"
        BldDist = repmat([1,1;1,1], 1); % 类型编号
    case "Same B buildings"
        BldDist = repmat([2,2;2,2], 1); % 类型编号
    case "Same C buildings"
        BldDist = repmat([3,3;3,3], 1); % 类型编号
    case "Same D buildings"
        BldDist = repmat([4,4;4,4], 1); % 类型编号
    case "Four different buildings"
        BldDist = repmat([1,3;2,4], 1); % 类型编号
end

% 绘图
BldH = [11.8,31.68,11.8,31.68]; % 高度
BldL = [36.6,45.75,36.6,45.75]; %宽度
Plot_Bld(density,BldDist,BldH,BldL);

%% 定义震源、场地信息
IMSim_dir = 'IMSim';

EQSourceFile = 'EQSource.txt'; % 震源信息文件
ifmedian = 1; % 0为随机
M = 8;
N_sim = 10000;
seed = 2;
lon_0 = 0; 
% lat_0 = 0;
lat_0 = 10/6370.856*180/pi;  % 中心以北10km
W = 10;
length = 10;
RuptureNormal_x = 1; RuptureNormal_y = 0; RuptureNormal_z = 1;
lambda = 270;
Fhw = 1;
Zhyp = 15;
region = 3;
nPCs = 10;
writecell({ifmedian;M;N_sim;seed;[lon_0,lat_0]; ...
    W;length;[RuptureNormal_x,RuptureNormal_y,RuptureNormal_z]; ...
    lambda;Fhw;Zhyp;region;nPCs},fullfile(IMSim_dir,EQSourceFile),'Delimiter',' ');

T0_vec = [Capacity2D.T]; 
SiteFile = 'SiteFile_BldDistType_ABCD.txt'; % 场地信息文件
ID_mat = GenerateSiteFile( ...
    fullfile(IMSim_dir,'SiteFile_BldDistType_ABCD.txt'), ...
    BldDist,T0_vec,density);

%% IM模拟
oldFolder = cd(IMSim_dir);
status = system(['IMSim ',EQSourceFile,' ',SiteFile]);
cd(oldFolder);
IM_mat = ReadIMSim(ID_mat,fullfile(IMSim_dir,'IM sim.txt'));
[X,Y] = meshgrid(1:size(BldDist,2),1:size(BldDist,1));
Plot_IM_Spatial(median(IM_mat,3),X,Y);

%% 损失模拟
SP_type = 'RC'; 
load(['CovFunMat_',SP_type,'.mat']);

% IM烈度场
Bool_ConstIM = false;
if Bool_ConstIM
    % 常数烈度
    N_LossSim = 10000; % 损失模拟次数
    IM_mat = repmat(0.2.*ones(size(BldDist)),1,1,N_LossSim); 
else
    % 利用前面模拟的随机烈度场结果
end

% 三种情况：部分相关、完全相关、独立
[LossSim_0,LossMat0] = SimulateRegionalLoss(IM_mat,SP_type,density,BldDist, ...
    Capacity2D,CovFunMat,0);
[f_0,x_0] = ecdf(LossSim_0);
[LossSim_1,LossMat1] = SimulateRegionalLoss(IM_mat,SP_type,density,BldDist, ...
    Capacity2D,CovFunMat,1);
[f_1,x_1] = ecdf(LossSim_1);
[LossSim_2,LossMat2] = SimulateRegionalLoss(IM_mat,SP_type,density,BldDist, ...
    Capacity2D,CovFunMat,2);
[f_2,x_2] = ecdf(LossSim_2);

% 绘图
Plot_Loss_CDF({x_0,x_1,x_2},{f_0,f_1,f_2});
if ~contains(BldDistType,'same','IgnoreCase',true)
    xlim([1.3,2.2].*10^7);
end
title('RC-AAAA-100m-ConstIM','FontWeight','normal');

%% 绘图：建筑群损失3D
SP_type = 'RC';
maxloss = 8*10^9/400;
Plot_RegionalLoss(SP_type,density,LossMat2(:,:,2),BldDist,BldH,BldL,maxloss);


