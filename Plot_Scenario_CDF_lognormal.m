function [Samples,RSN_vec_,IMs_] = Plot_Scenario_CDF_lognormal(T,IMList,method, ...
    IDA_EDP, Scenario_EDP, Scenario_RSN, EQDataStruct, ...
    Sa_Scenario_filter, ifplot)
% 绘制一次场景地震的某个结构的 (log(EDP)-lgMean)/lgSigma 的累积分布
%
% 输入：
% T - 结构周期，用来确定Sa
% IMList - 结构IDA分析的IM向量, 从小到大
% method - 方法： 1-'lognormal',对数正态分布；2-'empirical'经验累积分布函数；
% IDA_EDP - 结构IDA分析的EDP, EDP(i_EQ,i_IM)
% Scenario_EDP - Scenario分析的EDP, EDP(i_RSN)
% Scenario_RSN - Scenario分析的每条地震波的RSN, RSN(i_RSN)
% EQDataStruct - 所有地震波的元数据结构体
% Sa_Scenario_filter - [min,max]过滤Sa Sa_Scenario_filter之外的结果
% ifplot - 是否绘图
%
% 输出：
% Samples - 场景地震的 (log(EDP)-lgMean)/lgSigma 的观测值
% RSN_vec_ - 对应的RSN编号
% IMs - 对应的Sa(T)

% Sa_Scenario_filter
i_vec = true(1,numel(Scenario_RSN));
for i_EQ=1:numel(Scenario_RSN)
    RSN = Scenario_RSN(i_EQ);
    T_Sa = EQDataStruct([EQDataStruct.RecordSequenceNumber]==RSN).Sa;
    Sa = interp1(T_Sa(1,:),T_Sa(2,:),T);
    if (Sa<Sa_Scenario_filter(1)) || (Sa>Sa_Scenario_filter(2))
        i_vec(i_EQ)=false;
    else
        i_vec(i_EQ)=true;
    end
end
Scenario_EDP = Scenario_EDP(i_vec);
Scenario_RSN = Scenario_RSN(i_vec);

Samples = zeros(1,numel(Scenario_RSN));
RSN_vec = zeros(1,numel(Scenario_RSN));
IMs = zeros(1,numel(Scenario_RSN));
for i_EQ=1:numel(Scenario_RSN)
    RSN = Scenario_RSN(i_EQ);
    EDP = Scenario_EDP(i_EQ);
    T_Sa = EQDataStruct([EQDataStruct.RecordSequenceNumber]==RSN).Sa;
    Sa = interp1(T_Sa(1,:),T_Sa(2,:),T);
    IMs(i_EQ) = Sa;
    % 寻找IM最近的值插值
    i_IM_down = find((Sa-IMList)>=0,1,'last'); 
    i_IM_up = find((IMList-Sa)>=0,1);
    if isempty(i_IM_down) % 低于了IDA分析的IM下限
        i_IM_down = i_IM_up;
        i_IM_up = i_IM_down + 1;
    elseif isempty(i_IM_up) % 超过了IDA分析的IM上限
        i_IM_up = i_IM_down;
        i_IM_down = i_IM_up - 1;
    end
    % eps
    pd = makedist('Normal');
    epsilon_up = find_epsilon_from_samples(EDP,IDA_EDP(:,i_IM_up),method);
    epsilon_down = find_epsilon_from_samples(EDP,IDA_EDP(:,i_IM_down),method);
    Samples(i_EQ) = icdf(pd,mean(cdf(pd,[epsilon_up,epsilon_down])));
    % 处理inf
    if isinf(Samples(i_EQ))
        if Samples(i_EQ)>0
            Samples(i_EQ) = 5;
        else
            Samples(i_EQ) = -5;
        end
    end
    RSN_vec(i_EQ) = RSN;
end

if nargout>1
    RSN_vec_ = RSN_vec;
end

if nargout>2
    IMs_ = IMs;
end

if ~ifplot
    return;
end

tiledlayout('flow','TileSpacing','none','Padding','none');
hold on; 

p = plot(-3:0.05:3, normcdf(-3:0.05:3));
s = scatter(sort(Samples), (1:numel(Samples))./numel(Samples));
legend([p s],{'Standard normal distribution','Samples'})

box on;
xlabel('$\epsilon$','Interpreter','latex');
ylabel('$\mathrm{CDF}$','Interpreter','latex');
% title('$(0.5\theta_y,\theta_y)$','Interpreter','latex');
ax = gca; 
ax.FontSize = 12;
ax.FontName = 'Times New Roman';
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);

end


