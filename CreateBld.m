function p = CreateBld(loc,length,Height,facecolor)
% 创建建筑的模型
%
% 输入：
% loc - [x,y]中心的坐标
% length - 底部矩形的长度
% Height - 高度
% facecolor - 颜色, 'r','g'
%
% 输出：
% p - 补片对象

vert = [0 0 0;1 0 0;1 1 0;0 1 0;0 0 1;1 0 1;1 1 1;0 1 1];
vert(:,1:2) = vert(:,1:2) - 0.5;
vert(:,3) = Height.*vert(:,3);
vert(:,1:2) = length.*vert(:,1:2);
vert(:,1) = vert(:,1) + loc(1);
vert(:,2) = vert(:,2) + loc(2);

fac = [1 2 6 5;2 3 7 6;3 4 8 7;4 1 5 8;1 2 3 4;5 6 7 8];
p = patch('Vertices',vert,'Faces',fac, ...
    'FaceVertexCData',hsv(6),'FaceColor',facecolor,'FaceAlpha',1); %facecolor

view(3);
axis vis3d;
daspect([1 1 1]);
% box on;
axis off;
xticks([]);
yticks([]);
zticks([]);
  
end

