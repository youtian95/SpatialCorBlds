function P = Plot_EmpiricalCDF(X,N_x)
% 经验累积分布函数
% 
% 输入：
% X - [i_Sim,i_IM]，观测值
% N_x - 曲线散点的数量
%
% 输出：
% P - Matrix(:,:,i_IM) 为 2 x N_x 矩阵，第一行为 x坐标（从0-end），第
%       二行为对应的 P(x) 概率

N_IM = size(X,2);
P = zeros(2,N_x+1,N_IM);
N_sim = size(X,1);

for i_IM = 1:N_IM
    x_max = max(X(:,i_IM));
    x_max = max(x_max,1);
    P(1,:,i_IM) = 0:(x_max/N_x):x_max;
    for j=1:(N_x+1)
        P(2,j,i_IM) = sum(X(:,i_IM) <= P(1,j,i_IM))/N_sim;
    end
end

hold on;
for i_IM = 1:N_IM
    plot(P(1,:,i_IM),P(2,:,i_IM), ...
        'LineWidth',1.5);
end

box on;
grid on;
% xlabel('$\mathrm{Drirft}$','Interpreter','latex');
ylabel('$\mathrm{CDF}$','Interpreter','latex');
% title(['$S_{a,y}=',num2str(IM_1),'\ \mathrm{g},\ T=', , ...
%     '$'],'Interpreter','latex');
ax = gca; 
legend1 = legend(ax,'show');
ax.FontSize = 14;
ax.FontName = 'Times New Roman';
ax.YLim = [0,1];
% ax.XLim = [0,10];
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);


end

function createfigure(X1, Y1, X2, X3)
%CREATEFIGURE(X1, Y1, X2, X3)
%  X1:  x 数据的向量
%  Y1:  y 数据的向量
%  X2:  x 数据的向量
%  X3:  x 数据的向量

%  由 MATLAB 于 17-Mar-2022 16:25:29 自动生成

% 创建 figure
figure('OuterPosition',...
    [14.7864285714286 5.86619047619048 10.3565476190476 10.2507142857143]);

% 创建 axes
axes1 = axes;
hold(axes1,'on');

% 创建 plot
plot(X1,Y1,'DisplayName','IM = 0.5g','LineWidth',1.5);

% 创建 plot
plot(X2,Y1,'DisplayName','IM = 1g','LineWidth',1.5);

% 创建 plot
plot(X3,Y1,'DisplayName','IM = 3g','LineWidth',1.5);

% 创建 ylabel
ylabel('$\mathrm{CDF}$','FontName','Times New Roman','Interpreter','latex');

% 创建 xlabel
xlabel('$\mathrm{Repair\ Cost}\ (\$10^6)$','FontName','Times New Roman',...
    'Interpreter','latex');

% 取消以下行的注释以保留坐标区的 Y 范围
% ylim(axes1,[0 1]);
box(axes1,'on');
grid(axes1,'on');
hold(axes1,'off');
% 设置其余坐标区属性
set(axes1,'FontName','Times New Roman','FontSize',14);
% 创建 legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.493870357435585 0.556894600476162 0.315052956207437 0.203686206752212]);
end


