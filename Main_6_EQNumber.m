%% 地震动数量需求研究

%% 重新运行 Main_5_EQStationSelection.m 脚本获得不同地震动数量的相关函数
for N_EQ = 20
    run('Main_5_EQStationSelection.m');
    filename = ['CovFunMat_Partial',num2str(N_EQ),'_IDR.mat'];
    save(filename,'CovFunMat*','LogLikelihood*');
    clear;
end

%% 绘图：对比最大似然函数对数值

listing = dir('CovFunMat_Partial*_IDR.mat');
S0 = load('CovFunMat_IDR.mat');
Plot_LogLikelihood(listing,S0);
legend('Set 1','Set 2','Set 3');
xlabel('Number of records');
ylabel('Log-likelihood function');