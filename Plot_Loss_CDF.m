function Plot_Loss_CDF(x,f)
% 输入：
% x,f - 元胞，各自单增

hold on;
p = [];
for i=1:numel(x)
    p1 = plot(x{i},f{i},'LineWidth',2); %./max(x_0)
    p = [p,p1];
end

p(1).LineStyle = '--';
p(3).Color = [0 0.4470 0.7410];

p(2).LineStyle = ':';
p(2).LineWidth = 2.5;
p(3).Color = [0.6350 0.0780 0.1840];

p(3).LineStyle = '-';
p(3).Color = [0.4660 0.6740 0.1880];

lgd = legend('Independent','Perfectly Correlated','GRF-based',Location='southeast');
lgd.Box = 'off';

box on;
grid on;
xlabel('Total Losses ($)');
ylabel('\itP \rm(\itX<x\rm)');
% title(['$S_{a,y}=',num2str(IM_1),'\ \mathrm{g},\ T=', , ...
%     '$'],'Interpreter','latex');
ax = gca; 
ax.FontSize = 14;
ax.FontName = 'Calibri';
% ax.YLim = [0,1];
ax.YLim = [0.5,0.95];
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8.5]);

end

