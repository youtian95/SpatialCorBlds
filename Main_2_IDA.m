% 2D结构的IDA分析

%% 其他工具
addpath('3rd Party\PACT tool');
addpath('3rd Party\Collapse fragility fitting');
addpath('3rd Party\Fitting seismic hazard curve');

%% IDA分析
BldName = 'MRF3';

% IMList = [0.011,0.021]; %测试
IMList = [0.01,0.1,0.125,0.15,0.175,0.2, ...
    0.225,0.25,0.275,0.3,0.35, ...
    0.4,0.45,0.5,0.6,0.7,0.707,0.8,0.9,1, ...
    1.1,1.2,1.3,1.4,1.5,2,3,4,5]; % MRF3
OutputDir = 'Results'; 
IDA_2D(['Opensees FEM models\',BldName],IMList,OutputDir);

%% 读取IDA分析结果
i_struct=4;
BldName = 'SCBF9';
Nstory = 9;

% IMList = [0.01,0.1,0.125,0.15,0.175,0.2, ...
%     0.225,0.25,0.275,0.3,0.35, ...
%     0.4,0.45,0.5,0.6,0.7,0.707,0.8,0.9,1, ...
%     1.1,1.2,1.3,1.4,1.5,2,3,4,5]; % MRF3
% IMList = [0.01,0.1,0.12,0.14,0.16,0.18,0.2, ...
%     0.22,0.24,0.26,0.28,0.3, ...
%     0.32,0.34,0.36,0.38, ...
%     0.4,0.5,0.6,0.7,0.8,0.9,1, ...
%     1.1,1.2,1.5,2,3,4,5]; % MRF9

% 读取当前结果
Capacity2D_temp = Read_2D_IDA(['Opensees FEM models\',BldName],Nstory);
Capacity2D_temp.ModelName = BldName;
Capacity2D_temp.T = ReadStructPeriods(BldName,1);
Capacity2D_temp.medianSa = [];
Capacity2D_temp.sigmalnSa = [];
Capacity2D_temp.RT = [];
Capacity2D_temp.RC = [];

%% 合并已有的IDA结果
if exist('Capacity2D','file')==2
    load("Capacity2D.mat");
    Capacity2D(i_struct) = Capacity2D_temp;
else
    Capacity2D(i_struct) = Capacity2D_temp;
end

%% IDA分析绘图
i_struct=3;
IM_plotpdf = 3;

Plot_IDA(Capacity2D(i_struct).IMList, ...
    Capacity2D(i_struct).IDA_Max_Drift(:,:)', ...
    [0.1,inf], IM_plotpdf);
xlim([0,0.015]);
ylim([0,4]);

%% 抗倒塌能力分析、绘图
i_struct=2; 
Collapse_Drift = 0.02;

d = Capacity2D(i_struct).IDA_Max_Drift;
Pcon = sum(d>Collapse_Drift,1)./size(d,1);
objC=CollFrag(Capacity2D(i_struct).IMList,Pcon);
Capacity2D(i_struct).medianSa = objC.medianSa;
Capacity2D(i_struct).sigmalnSa = objC.sigmalnSa;
plotFit(objC);

%% 地震损失分析
i_struct=4; 
BldName = Capacity2D(i_struct).ModelName;

% 生成文件
filename = ['seismic loss assessment\EDP Input files ',BldName,' IDA.csv'];
CreatePactEDPfile(filename,Capacity2D(i_struct).IMList, ...
    Temp_EDPMat_2_EDPCell(Capacity2D(i_struct).IDA_drift), ...
    Temp_EDPMat_2_EDPCell(Capacity2D(i_struct).IDA_accel), ...
    Temp_EDPMat_2_EDPCell(Capacity2D(i_struct).IDA_vel), ...
    Temp_EDPMat_2_EDPCell(Capacity2D(i_struct).RDrift), ...
    Temp_EDPMat_2_EDPCell(Capacity2D(i_struct).PGA), ...
    Temp_EDPMat_2_EDPCell(Capacity2D(i_struct).PGV), ...
    @SHC, Capacity2D(i_struct).T, [1,1,0]);

% 手动操作PACT进行损失分析
% 输出三个文件：
%   RealCost_AllFloorsAllDirsAllPGs.csv
%   RealTime_AllFloorsAllDirsAllPGs.csv
%   UnsafePlacardSummary_All.csv

%% 读取地震损失分析结果 P(x) RC RT
i_struct=4;
BldName = Capacity2D(i_struct).ModelName;

[RT,RC] = Read_RTRC_Sim_From_PactDir(['.\seismic loss assessment\',BldName,' RTRCresults IDA']);
Capacity2D(i_struct).RT = RT';
Capacity2D(i_struct).RC = RC';

%% 地震损失分析绘图
i_struct=1;
IMplot = [0.2,0.5,1,2,5]; % 需要绘制的IM

[row,col] = find(IMplot'==Capacity2D(i_struct).IMList);
Plot_EmpiricalCDF(Capacity2D(i_struct).RC(:,col), 500); %500个x坐标
legend(split(num2str(IMplot)));



