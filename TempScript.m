listing = dir('CovFunMat_Partial*_IDR.mat');
S0 = load('CovFunMat_IDR.mat');
Plot_LogLikelihood(listing,S0);
legend('Set 1','Set 2','Set 3','Set 4','Set 5');
xlabel('Number of records');
ylabel('Log-likelihood function');