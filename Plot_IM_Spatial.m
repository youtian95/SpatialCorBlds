function Plot_IM_Spatial(IM_mat,X,Y)
% IM模拟绘图
% 
% 输入：
% IM_mat - size(ID_mat)
% X,Y - x,y坐标网格 size(ID_mat)

Plotfigure_IM(IM_mat,Y,X);

end

function Plotfigure_IM(ZData1, YData1, XData1)
%CREATEFIGURE(ZData1, YData1, XData1)
%  ZDATA1:  surface zdata
%  YDATA1:  surface ydata
%  XDATA1:  surface xdata

%  由 MATLAB 于 16-Mar-2022 15:47:35 自动生成

% 创建 figure
figure1 = figure;

% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 创建 surface
surface('Parent',axes1,'ZData',ZData1,'YData',YData1,'XData',XData1,...
    'MarkerFaceColor',[1 0 0],...
    'MarkerSize',5,...
    'Marker','o',...
    'FaceAlpha',0.6,...
    'FaceColor',[0.650980392156863 0.650980392156863 0.650980392156863],...
    'EdgeAlpha',0.6,...
    'EdgeColor',[0.149019607843137 0.149019607843137 0.149019607843137],...
    'CData',ZData1);

% 创建 zlabel
zlabel('$S_a (\mathrm{g})$','FontName','Times New Roman',...
    'Interpreter','latex');

% 创建 ylabel
ylabel('Y (50 m)','FontName','Times New Roman');

% 创建 xlabel
xlabel('X (50 m)','FontName','Times New Roman');

% 取消以下行的注释以保留坐标区的 Z 范围
zlim(axes1,[0 3]);
view(axes1,[-37.2 31.8]);
box(axes1,'on');
grid(axes1,'on');
hold(axes1,'off');
% 设置其余坐标区属性
set(axes1,'FontName','Times New Roman','FontSize',16);


end
