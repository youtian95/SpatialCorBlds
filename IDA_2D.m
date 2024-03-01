function IDA_2D(MainDir,IMList,OutputDir)
% 2D结构的IDA分析, 一个OutputDir文件夹对应一个结构
%
% 输入：
% 
% MainDir - tcl文件夹, 'Opensees FEM models\SDOF'
% IMList - IM向量
% OutputDir - 结果输出文件, 相对于 .tcl文件的目录

% T1 = T;
% T2 = T;

% 修改 NXFmodel.tcl
% filename = fullfile(MainDir,'NXFmodel.tcl');
% filename_new = fullfile(MainDir,'NXFmodel.tcl');
% 修改 Sa_yield
% startPat = 'set Sa_yield ';
% endPat = ';';
% newText = num2str(Sa_yield*9.8*1000,'%0.5f'); %单位从 g 转为 mm/s~2
% modifyfile(filename,filename_new,startPat,endPat,newText);
% 修改 T
% startPat = 'set T ';
% endPat = ';';
% newText = num2str(T,'%0.2f');
% modifyfile(filename_new,filename_new,startPat,endPat,newText);

run(fullfile(MainDir,'IntensityBasedAnalysis.m'));


end
