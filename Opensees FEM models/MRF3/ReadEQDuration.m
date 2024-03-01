function t = ReadEQDuration(filePath1,filePath2)
% 读取地震波持时
% 
% 输入：
% filePath1,filePath2 两个方向的时程文件

temp1 = readmatrix(filePath1);
temp2 = readmatrix(filePath2);
t = max(temp1(end,1),temp2(end,1));

end