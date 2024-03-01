% 场景地震分析
% 输入：
% EQDir - 地震波数据文件夹, 对EQDir中所有地震波进行分析
% T1 - X方向周期
% T2 - Y方向周期
% OutputDir - 结果输出文件

% EQDir = '../Northridge19940117';
Tfile = readmatrix(dir('modesPeriods*.txt').name); % 从结果读取周期
T1 = Tfile(1);
T2 = Tfile(1);
% OutputDir = 'Scenario Northridge19940117 ';

MetaData = readmatrix(fullfile(EQDir,'MetaData.txt'), ...
    'OutputType','string','Delimiter',',');
T = (T1+T2)/2;
% EQ j
parfor j=1:size(MetaData,1) % parfor
    filePath1 = fullfile(EQDir,MetaData(j,2));
    filePath1 = replace(filePath1,'\','/');
    filePath2 = fullfile(EQDir,MetaData(j,3));
    filePath2 = replace(filePath2,'\','/');
    pSa1 = pSaFromPeriod(fullfile(EQDir,MetaData(j,6)),T);
    pSa2 = pSaFromPeriod(fullfile(EQDir,MetaData(j,7)),T);
    pSa = sqrt(pSa1*pSa2);
    ampl1 = 1*9.81*1000; 
    ampl2 = 1*9.81*1000;
    Duration = ReadEQDuration(filePath1,filePath2)+20; %持时多20s
    dir_EQ_i = fullfile(OutputDir,['EQ',num2str(j)]);
    status = mkdir(dir_EQ_i);
    dir_EQ_i_X = fullfile(dir_EQ_i,'Dir1');
    dir_EQ_i_Y = fullfile(dir_EQ_i,'Dir2');
    dir_EQ_i_X = replace(dir_EQ_i_X,'\','/');
    dir_EQ_i_Y = replace(dir_EQ_i_Y,'\','/');
    MainFileName_X = ['main_EQ',num2str(j),'_X.tcl'];
    MainFileName_Y = ['main_EQ',num2str(j),'_Y.tcl'];
    WriteMainTclFile(MainFileName_X, ...
        dir_EQ_i_X,filePath1,ampl1,Duration);
    WriteMainTclFile(MainFileName_Y, ...
        dir_EQ_i_Y,filePath2,ampl2,Duration);
    system(['OpenSees ',MainFileName_X]);
    system(['OpenSees ',MainFileName_Y]);
    delete(MainFileName_X);
    delete(MainFileName_Y);
end




