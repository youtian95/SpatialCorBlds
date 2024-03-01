function IM_mat = ReadIMSim(ID_mat,IMSimFile)
%UNTITLED4 此处显示有关此函数的摘要
% 
% 输入：
% ID_mat - 与BldDist对应大小的矩阵，为每个建筑的ID
% IMSimFile - 'IM sim.txt'
%
% 输出：
% IM_mat - [size(ID_mat),N_sim]

A = readmatrix(IMSimFile);

IM_mat = zeros([size(ID_mat),size(A,2)-1]);

for row=1:size(ID_mat,1)
   for col=1:size(ID_mat,2)
       ID = ID_mat(row,col);
       IM_mat(row,col,:) = A(A(:,1)==ID, 2:end);
   end
end

end

