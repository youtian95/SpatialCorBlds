%% 地震动处理
addpath('3rd Party\PEER record tool');

%% 读取一次历史地震的所有台站元数据
MetaDataFile = ['PEER NGA Data\NGA_West2_flatfiles\', ...
   'Updated_NGA_West2_Flatfile_RotD50_d050_public_version.xlsx'];
if 0
    EQName = 'Northridge';
    EQDate = '19940117';
    EQTimeSeriesDir = { ...
        'PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup0-40', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup40-200'};
else
    EQName = 'Chi-Chi';
    EQDate = '19990920';
    EQTimeSeriesDir = { ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup0-30', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup30-55', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup55-80', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup80-100', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup100-1000'};
end
EQDataStruct = Read1ScenarioEQData(MetaDataFile, EQName, EQDate, EQTimeSeriesDir);

%% 台站位置绘图
RSN_Filter = [EQDataStruct.AccHistoryFileExist] ...
    & ([EQDataStruct.PGA_g_]>=0.05); % PGA大于0.05g
Plot_StationMap(EQDataStruct, EQName, RSN_Filter);

%% 输出用于场景地震结构分析的台站地震动时程
if strcmp(EQName,'Northridge')
    dir_in = {'PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup0-40', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup40-200'};
    dir_out = 'Opensees FEM models\EQ Records\Northridge19940117';
elseif strcmp(EQName,'Chi-Chi')
    dir_in = {'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup0-30', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup30-55', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup55-80', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup80-100', ...
        'PEER NGA Data\PEERNGARecords_Unscaled_ChiChi_Rrup100-1000'};
        dir_out = 'Opensees FEM models\EQ Records\Chi-Chi19990920';
end
% 只使用部分满足要求的台站地震动
RSN_Filter = [EQDataStruct.RecordSequenceNumber];
RSN_Filter = RSN_Filter([EQDataStruct.AccHistoryFileExist] ...
    & ([EQDataStruct.PGA_g_]>=0.05)); % PGA大于0.05g
OutputPeerGroundMotion(dir_in,dir_out,RSN_Filter);








