function [LossSim,LossMat] = SimulateRegionalLoss(IM_mat,SP_type,density, ...
    BldDist,Capacity2D,CovFunMat,ifcov)
% 模拟区域损失
%
% 输入：
% BldDist - 建筑类型，矩阵
% IM_mat - [size(BldDist),N_sim]
% SP_type - 'RC', 'RT', 'Collapse'
% density - 网格的距离 km
% Capacity2D
% CovFunMat - 相关系数函数句柄，max(BldDist) x max(BldDist)
% ifcov - 0:不考虑；1:完全相关；2:考虑
%
% 输出：
% LossSim - 各次模拟的总损失
% LossMat - 各个建筑的损失

% 相互距离
[X,Y] = meshgrid(1:size(BldDist,2),1:size(BldDist,1));
X = X.*density;
Y = Y.*density;
XY = [reshape(X,[],1),reshape(Y,[],1)];
dist_matrix = (XY(:,1)*ones(1,size(XY,1)) - (XY(:,1)*ones(1,size(XY,1)))').^2 ...
    + (XY(:,2)*ones(1,size(XY,1)) - (XY(:,2)*ones(1,size(XY,1)))').^2;
dist_matrix = sqrt(dist_matrix);

% 相关系数矩阵
TypeMat = reshape(BldDist,1,[]);
Sigma = eye(numel(BldDist));
switch ifcov
    case 0
    case 1
        Sigma(~eye(numel(BldDist)))=0.9999;
    case 2
        for i=1:numel(BldDist)
            for j=(i+1):numel(BldDist)
                h = dist_matrix(i,j);
                if TypeMat(i)==TypeMat(j)
                    Sigma(i,j) = CovFunMat{TypeMat(i),TypeMat(j)}(h);
                else
                    temp = CovFunMat{TypeMat(i),TypeMat(j)}(h);
                    Sigma(i,j) = temp;
                end
                Sigma(j,i) = Sigma(i,j);
            end
        end
        delta = 0.1;
        Sigma = ConvertSymmetricalMatrixtoSemiPositive( ...
            Sigma,delta);
    otherwise
end

% 模拟损失
N_sim = size(IM_mat,3);
LossMat = zeros([size(BldDist),N_sim]);
LossSim = zeros(1,N_sim);
for i_sim = 1:N_sim
    SP = zeros(size(BldDist));
    epsilon = mvnrnd(zeros(1,numel(BldDist)),Sigma);
    epsilon = reshape(epsilon,size(BldDist));
    Interval_ZeroOne = cdf('Normal',epsilon,0,1);
    for row = 1:size(BldDist,1)
        for col = 1:size(BldDist,2)
            IM = IM_mat(row,col,i_sim);
            type = BldDist(row,col);
            IMList = Capacity2D(type).IMList;
            [~,NearestIM] = min(abs(IMList-IM));
            switch SP_type
                case {'RC','RT'}
                    SP_sim = Capacity2D(type).(SP_type)(:,NearestIM);
                    Int_temp = ceil(numel(SP_sim)*Interval_ZeroOne(row,col));
                    SP_sim = sort(SP_sim);
                    SP(row,col) = SP_sim(Int_temp,1);
                case {'Collapse'}
                    P_collapse = cdf('Lognormal',IM, ...
                        log(Capacity2D(type).medianSa), ...
                        Capacity2D(type).sigmalnSa);
                    if Interval_ZeroOne(row,col)>(1-P_collapse)
                        SP(row,col) = 1; % 倒塌
                    else
                        SP(row,col) = 0; 
                    end
                otherwise
            end
        end
    end
    LossMat(:,:,i_sim) = SP;
    LossSim(i_sim) = sum(SP,'all');
end

end



