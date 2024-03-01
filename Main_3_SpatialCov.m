% 抗震性能空间相关性分析

if 0
    EQName = 'Northridge19940117';
else
    EQName = 'Chi-Chi19990920';
end

addpath('3rd Party\WebMercator2LongLat');
addpath('3rd Party\PACT tool');
addpath('3rd Party\Gaussian Process Regression\');
addpath('3rd Party\Fitting seismic hazard curve\');
addpath('3rd Party\Convert Symmetrical Matrix to Semi Positive');
load("Capacity2D.mat");
load(['EQDataStruct_',EQName,'.mat']);

%% 每个台站的动力时程分析
MainDir = 'Opensees FEM models\MRF3';

EQDir = fullfile('..\EQ Records',EQName); % 相对于MainDir
OutputDir = ['Scenario ',EQName];  % 相对于MainDir  

Scenario_2D(MainDir,EQDir,OutputDir);

%% 读取场景地震分析结果
i_struct  =2;
BldName = 'MRF9';

ScenarioName = ['Scenario ',EQName];
EQDir = fullfile('Opensees FEM models\EQ Records',EQName);
ExistingDATA = ['ScenarioAnalysis_',EQName];

NStory = str2num(BldName(end));

ScenarioStruct_temp = Read_2D_Scenario(NStory, ...
    ['Opensees FEM models\',BldName], ...
    ScenarioName, ...
    [EQDir,'\MetaData.txt']);
if exist(ExistingDATA,'file')==2
    load([ExistingDATA,'.mat']);
end
ScenarioStruct{i_struct} = ScenarioStruct_temp;
ScenarioStruct{i_struct}.ModelName = BldName;

%% 绘图: EDP结果绘图
i_struct = 2;
imagefile = 'Figures\Chi-Chi.png';

if contains(imagefile,"Northridge",'IgnoreCase',true)
    EpiLat = 34.213; EpiLong = -118.537;     
    left_long = -121; right_long = -116; 
    down_lat = 33; up_lat = 36;
elseif contains(imagefile,"Chi-Chi",'IgnoreCase',true)
    EpiLat = 23.85; EpiLong = 120.82;     
    left_long = 119; right_long = 123; 
    down_lat = 21; up_lat = 26;
end

% drift绘图
for i_EQ=1:numel(ScenarioStruct{i_struct}.max_drift) %PGA, max_drift
    long = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        ScenarioStruct{i_struct}.RSN(i_EQ)).StationLongitude;
    lat = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        ScenarioStruct{i_struct}.RSN(i_EQ)).StationLatitude;
    % drift
    Z(i_EQ,:) = [long,lat,ScenarioStruct{i_struct}.max_drift(i_EQ)]; %max_drift(i_EQ)
end
Plot_Scenario_Z(imagefile,Z, left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong);

%% 场景地震损失分析
i_struct=2;
BldName = Capacity2D(i_struct).ModelName;
ScenarioName = ['Scenario ',EQName];

for i=1:numel(ScenarioStruct{i_struct}.RSN)
    T_Sa = EQDataStruct( ...
        [EQDataStruct.RecordSequenceNumber]==ScenarioStruct{i_struct}.RSN(i)).Sa;
    IMList(i) = interp1(T_Sa(1,:),T_Sa(2,:),Capacity2D(i_struct).T);
end

% 生成EDP文件
filename = ['seismic loss assessment\EDP Input files ',BldName,' ',ScenarioName,'.csv'];
CreatePactEDPfile_Scenario(filename,IMList, ...
    ScenarioStruct{i_struct}.drift, ScenarioStruct{i_struct}.accel, ...
    ScenarioStruct{i_struct}.vel, ScenarioStruct{i_struct}.RDrift, ...
    ScenarioStruct{i_struct}.PGA, ScenarioStruct{i_struct}.PGV, ...
    0.001, 10, ...
    @SHC, Capacity2D(i_struct).T, ...
    [1,1,0]);

% 手动操作PACT进行损失分析
% 输出三个文件：
%   RealCost_AllFloorsAllDirsAllPGs.csv
%   RealTime_AllFloorsAllDirsAllPGs.csv
%   UnsafePlacardSummary_All.csv

%% 读取2D场景地震损失结果
i_struct=2;
BldName = Capacity2D(i_struct).ModelName;
ScenarioName = ['Scenario ',EQName];

ResultsPACTDir = ['seismic loss assessment\',BldName,' RTRCresults ',ScenarioName];
ScenarioStruct{i_struct} = Read_2D_Scenario_Loss( ...
    ScenarioStruct{i_struct},ResultsPACTDir);

%% 绘图: 场景地震统计结果绘图
Sa_Scenario_filter = [0.1,5];
IDA_EDPtype = {'IDA_drift','IDA_accel','IDA_vel','IDA_Max_Drift', ...
    'RT','RC'};
Scenario_EDPtype = {'drift','accel','vel','max_drift', ...
    'RT','RC'};

%% (1) 绘图：某个结构EDP epsilon的累积分布
i_struct= 2;
EDPtype = 4;
method = 'empirical';
XorY = 1; 
iStory = 1; 
ifplot = true;

[Samples,RSN_vec_,IMs_] = Plot_Scenario_CDF_lognormal( ...
    Capacity2D(i_struct).T, ...
    Capacity2D(i_struct).IMList,method, ...
    Capacity2D(i_struct).(IDA_EDPtype{EDPtype})(:,:,XorY,iStory), ...
    ScenarioStruct{i_struct}.(Scenario_EDPtype{EDPtype})(:,XorY,iStory)', ...
    ScenarioStruct{i_struct}.RSN', EQDataStruct, ...
    Sa_Scenario_filter, ifplot);

%% (2) 绘图：某个结构EDP epsilon的空间分布
i_struct=2;
EDPtype = 4;
method = 'empirical';
XorY = 1; 
iStory = 1; 

[samples,RSN] = Plot_Scenario_CDF_lognormal(Capacity2D(i_struct).T, ...
    Capacity2D(i_struct).IMList,method, ...
    Capacity2D(i_struct).(IDA_EDPtype{EDPtype})(:,:,XorY,iStory), ...
    ScenarioStruct{i_struct}.(Scenario_EDPtype{EDPtype})(:,XorY,iStory)', ...
    ScenarioStruct{i_struct}.RSN', EQDataStruct, ...
    Sa_Scenario_filter, false);
Plot_Scenario_Z_2(imagefile, samples, RSN, ...
    left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong);

%% (3) 绘图：对比所有结构的EDP余量的均值和标准差
EDPtype = 4; 
XorY = 1; 
iStory = 1; 

Plot_Scenario_EDPresidual_MeanSigma(Capacity2D, ...
    IDA_EDPtype, Scenario_EDPtype, ...
    'empirical', EDPtype, XorY, iStory, ...
    ScenarioStruct, ScenarioStruct{1}.RSN', ...
    EQDataStruct, ...
    Sa_Scenario_filter);

%% (4) 绘图：相关系数rho与距离的关系
EDPtype = 4;
i_A = 2; 
i_B = 2; %randi(50); % 两个结构
method = 'empirical';
XorY = 1; iStory = 1; 
x_plot = 2; deltaX = 1; % 绘制x_plot距离附近的coupla
Dist_inc = [5,7.5,10,20,30,40,50];

Plot_GP_rho(Capacity2D,ScenarioStruct,EQDataStruct, ...
    method,Sa_Scenario_filter, ...
    IDA_EDPtype, Scenario_EDPtype, ...
    i_A,i_B,EDPtype,XorY,iStory, ...
    x_plot, deltaX, 4, ...
    Dist_inc);

%% 相关性分析 6-'RC',5-'RT',4-'max_drift'
SP_type = 4;
Sa_Scenario_filter = [0.1,5];

load(['ScenarioAnalysis_',EQName]);
[CovFunMat,LogLikelihood] = AnalyzeCorrelationALL(SP_type,Sa_Scenario_filter, ...
    Capacity2D(2),EQDataStruct,ScenarioStruct(2));
% 手动保存CovFunMat,LogLikelihood至 CovFunMat_RC.mat

%% 绘图：相关性
Plot_rho_tile(CovFunMat);
