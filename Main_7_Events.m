% 对比Northridge19940117和Chi-Chi19990920地震的相关性

EQName = {'Northridge19940117','Chi-Chi19990920'};
i_bld = 2;
SP_type = 4;
Sa_Scenario_range = [0.1,5];

addpath('3rd Party\Gaussian Process Regression\');
addpath('3rd Party\WebMercator2LongLat');
addpath('3rd Party\Convert Symmetrical Matrix to Semi Positive');
load("Capacity2D.mat");
CovFunMat_vec = {};
for i=1:numel(EQName)
    load(['EQDataStruct_',EQName{i},'.mat']);
    load(['ScenarioAnalysis_',EQName{i},'.mat']);
    [CovFunMat,~] = AnalyzeCorrelationALL(SP_type,Sa_Scenario_range, ...
        Capacity2D(i_bld),EQDataStruct,ScenarioStruct(i_bld));
    CovFunMat_vec{i} = CovFunMat;
end
Plot_rho_tile(CovFunMat_vec);

f = gcf;
set(gcf,'units','normalized','position',[0.1 0.1 0.8 0.8]);
f.Children.Units = "centimeters";
f.Children.Position = [5 5 7 6];
legend('1994 Northridge','1999 Chi-Chi','Location','northeast');
title '';
ylabel('$\rm{cov}(\varepsilon_{IDR}^{C},\varepsilon_{IDR}^{C})$','Interpreter','latex');
xlabel('Distance (km)')

