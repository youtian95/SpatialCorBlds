function Plot_IDA(IM_list, Disp, IM_range, IM_plotpdf, IM_1, Disp_1)
% IDA绘图
% 
% 输入：
% IM_list - IM向量
% Disp - (i_IM,i_EQ)
% IM_range - 绘图范围大小 [min,max]
% IM_plotpdf - 绘制某一IM的pdf函数
% IM_1, Disp_1 - 正则化的横坐标和纵坐标

if nargin>2
    ind = (IM_list>=IM_range(1)) & (IM_list<=IM_range(2));
    IM_list = IM_list(ind);
    Disp = Disp(ind,:);
end

if nargin>4
    IM_list = IM_list./IM_1;
    Disp = Disp./Disp_1;
end

f = figure;
tiledlayout('flow','TileSpacing','none','Padding','none');
hold on;   
% individual
for i=1:size(Disp,2)
    p_ind = plot(Disp(:,i),IM_list,'Color',[0.7,0.7,0.7],'LineStyle','--');
end
% sigma
p_m = plot(exp(mean(log(Disp),2)),IM_list,'LineStyle','-','Color','k','LineWidth',1);
p_sigma1 = plot(exp(mean(log(Disp),2)-std(log(Disp),0,2)),IM_list,'LineStyle','-.','Color','k','LineWidth',1);
p_sigma2 = plot(exp(mean(log(Disp),2)+std(log(Disp),0,2)),IM_list,'LineStyle','-.','Color','k','LineWidth',1);

% 绘制某一IM的pdf函数
if nargin>3
    I = find(IM_list==IM_plotpdf);
    m = mean(log(Disp),2);
    s = std(log(Disp),0,2);
    x = linspace(0,max(Disp(I,:)));
    y = pdf('LogNormal',x,m(I),s(I));
    y = 0.5*(max(IM_list)-IM_plotpdf)./max(y).*y+IM_plotpdf;
    plot(x,y,'LineStyle','-','Color','r','LineWidth',1.5);
end


% 绘制某一IM的Cdf函数
if nargin>3
    I = find(IM_list==IM_plotpdf);
    m = mean(log(Disp),2);
    s = std(log(Disp),0,2);
    x = linspace(0,max(Disp(I,:)));
    y = cdf('LogNormal',x,m(I),s(I));
    figure;
    plot(x,y,'LineStyle','-','Color','r','LineWidth',1.5);
    axis off
    set(gcf,'Units','centimeters');
    set(gcf,'Position',[5 5 10 3]);
end

figure(f);

legend([p_m,p_sigma1,p_ind],{'Median','Median\pm\sigma','Individual'});
% legend([b1,b2],{'$P(\mathrm{CON}|S_a)$', ...
%     '$P(S_a|\mathrm{CON})$'}, ...
%     'FontSize',12,'Interpreter','latex');

% box on;
% grid on;
xlabel('Drirft Ratio');
ylabel('\itS\rm_{a}(g)');
% xlabel('$\mathrm{Drirft Ratio}$','Interpreter','latex');
% ylabel('$S_a\ (\mathrm{g})$','Interpreter','latex');
% title(['$S_{a,y}=',num2str(IM_1),'\ \mathrm{g},\ T=', , ...
%     '$'],'Interpreter','latex');
ax = gca; 
ax.FontSize = 16;
ax.FontName = 'Calibri';
% ax.YLim = [0,3];
% ax.XLim = [0,10];
ax.TickLength = [0 0];
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);

% 添加箭头
arrowAxes();



end

