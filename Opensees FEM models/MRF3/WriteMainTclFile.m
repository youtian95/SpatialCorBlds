function WriteMainTclFile(MainFileName, ...
    OutputDir,filePath1,ampl1,maxtime)
% 创建Main.tcl文件, 定义了$filePath1, $filePath2, $ampl1, $ampl2, 
% $maxtime, $OutputDir变量, 然后定义结构进行时程分析
%
% 输入
% MainFileName              main.tcl文件名
% OutputDir                 Recorders输出文件夹
% filePath1                 x方向的地震动时程曲线文件名
% ampl1                     对应的放大系数, 比如 9.81*1000
% maxtime                   分析的总时长，应为地震动时长加20s

fileID = fopen(MainFileName,'w');

% 定义参数
fprintf(fileID, '# Created by Matlab script\r\n');
fprintf(fileID, 'set OutputDir "%s";\r\n', OutputDir);
fprintf(fileID, 'set filePath1 "%s";\r\n', filePath1);
fprintf(fileID, 'set ampl1 %f;\r\n', ampl1);
fprintf(fileID, 'set maxtime %f;\r\n', maxtime);

% 引用.tcl文件
fprintf(fileID, ...
['source NXFmodel.tcl;\r\n', ...
'source Nodemass.tcl;\r\n', ...
'source Gravity.tcl;\r\n', ...
'wipeAnalysis;\r\n', ...
'setRayleigh 0.02 1 2;\r\n', ...
'DynamicAn $maxtime 0.01 $filePath1 101 1 1e-4 $ampl1 $modelName $OutputDir;\r\n']);
fclose(fileID);

if exist(OutputDir,'dir')~=7
    status = mkdir(OutputDir);
end

end