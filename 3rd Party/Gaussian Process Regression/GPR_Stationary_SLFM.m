classdef GPR_Stationary_SLFM < handle
    % 多输出值的稳态高斯过程回归，固定均值，固定方差
    % Semiparametric Latent Factor Model方法
    
    properties 
        A % 超参数，核函数的组合系数，Do X Q
        Q % 独立高斯场u的数量
        HyperPara2 
        % 核函数的超参数: Q x N_HyperPara
        % 1 - squaredexponential: [l]
        % 2 - exponential: [l]
        % 3 - exponential_plus_constant: [l,C]
        % 4 - RationalQuadratic: [l,alpha]
        % 5 - RationalQuadratic_plus_constant: [l,alpha,C]
        % 6 - squaredexponential_plus_constant: [l, C]
        KernelType = 4 % Kernel - 核函数形式，k(xp,xq)
        algorithm = 'fmincon' % 求最小值算法 fminsearch fmincon ga
    end
    
    properties (Constant)
        KernelTypeList = {'squaredexponential','exponential', ...
            'exponential_plus_constant','RationalQuadratic', ...
            'RationalQuadratic_plus_constant', ...
            'squaredexponential_plus_constant'}
        N_HyperPara = [2,2,3,3,4,3] - 1 %超参数数量
    end
    
    properties (SetAccess = private)
        X % X - D x n，D维输入列向量，n个观测值的坐标 
        Y % Y - n x Do，观测值，n次观测，Do维输出
    end
    
    methods
        function obj = GPR_Stationary_SLFM(X,Y)
            % X - 输入单位km
            assert(size(X,2)==size(Y,1));
            % obj.X = X.*10^8;
            obj.X = X;
            obj.Y = Y;
            obj.Q = 2*size(Y,2);
        end
        
        function [exitflag,exitinfo] = Optimize(obj,A0,Kernal0)
            % 最大似然估计得到 obj.HyperPara2和obj.A
            %
            % 输入：
            % A0,Kernal0 - 初始值
            % lb,ub - 参数的上下限
            %
            % 输出：
            % exitflag - 1 表示成功
            % exitinfo - 迭代信息
            Do = size(obj.Y,2);
            n = size(obj.X,2);
            N_para = obj.N_HyperPara(obj.KernelType);
            fun = @(x) -LogLikelihood(obj,obj.Y,obj.X, ...
                reshape(x(1:(Do*obj.Q)),Do,obj.Q), ... % A
                reshape(x((Do*obj.Q+1):end),obj.Q,N_para)); % HyperPara2
            % 初始值
            if nargin<2
                A0 = eye(Do,obj.Q);
                HyperPara2_0 = 0.1.*ones(obj.Q,N_para);
            else
                HyperPara2_0 = Kernal0;
            end
            x0 = [reshape(A0,1,[]),reshape(HyperPara2_0,1,obj.Q*N_para)];

            Method = obj.algorithm;
            % 上下限
            lb = 0.00001 + zeros(1,Do*obj.Q+obj.Q*N_para);
            lb(1:(Do*obj.Q)) = -inf;
            ub = [];
            % 约束
            % nonlcon = @(x) Qnonlcon(x,Do,obj.Q); % A每一行的平方和等于1，非线性约束
            nonlcon = [];
            nvars = numel(x0);
            if strcmp(Method,'fmincon')
                % 选项
                % options = optimoptions('fmincon', 'Algorithm','sqp', ...
                %     'MaxFunctionEvaluations',10*numel(x0),'PlotFcns','optimplotfval');
                options = optimoptions('fmincon', 'Algorithm','sqp', ...
                    'MaxIterations', 2000*numel(x0),'MaxFunctionEvaluations',2000*numel(x0), ...
                    'PlotFcns','optimplotfval'); %,'StepTolerance',1e-20
                % 优化
                [HyperPara_opt,~,exitflag,exitinfo] = fmincon(fun,x0,[],[],[],[],lb,ub,nonlcon,options);
            elseif strcmp(Method,'fminsearch')
                options = optimset('MaxIter',1000*numel(x0),'MaxFunEvals',1000*numel(x0), ...
                    'PlotFcns',@optimplotfval);
                [HyperPara_opt,~,exitflag,exitinfo] = fminsearch(fun,x0,options);
            elseif strcmp(Method,'particleswarm')
                options = optimoptions('particleswarm','PlotFcn','pswplotbestf');
                [HyperPara_opt,~,exitflag,exitinfo] = particleswarm(fun,nvars,lb,ub,options);
            elseif strcmp(Method,'ga')
                options = optimoptions('ga','PlotFcn', @gaplotbestf);
                [HyperPara_opt,~,exitflag,exitinfo] = ga(fun,nvars,[],[],[],[],lb,ub,nonlcon,options);
            end
            obj.A = reshape(HyperPara_opt(1:(Do*obj.Q)),Do,obj.Q);
            obj.HyperPara2 = reshape(HyperPara_opt((Do*obj.Q+1):end),obj.Q,N_para);
        end
        
        function cov = GetCovariance(obj,d)
            % 根据距离返回协方差 
            % 输入：
            % d - 行向量
            % 输出：
            % cov(Do,Do,numel(d)) 例如 (f1(0),f2(0)) x (f1(d),f2(d))
            % d = d.*10^8;
            d = d;
            
            Do = size(obj.Y,2);
            cov = zeros(Do,Do,numel(d));
            KernelF = str2func(['GPR_Stationary_SLFM.', ...
                obj.KernelTypeList{obj.KernelType}]);
            for k=1:numel(d)
                for i=1:obj.Q
                    cov(:,:,k) = cov(:,:,k) + GPR_Stationary_SLFM.Bi(obj.A,i) ...
                        .* KernelF(d(k),[1,obj.HyperPara2(i,:)]);
                end
            end
        end

        function f = getLogLikelihood(obj,Y,X)
            % 根据观测值计算当前obj的最大似然函数对数值
            % 
            % 输入：
            % X - D x n，D维输入列向量，n个观测值的坐标
            % Y - n x Do，观测值，n次观测，Do维输出
            
            f = obj.LogLikelihood(Y,X,obj.A,obj.HyperPara2);
        end
    end
    
    methods (Access = private)
        function f = LogLikelihood(obj,Y,X,A,HyperPara2)
            % log p(y|X,theta)
            % Y - n x Do，观测值，n次观测，Do维输出
            y = reshape(Y,[],1);
            Kf = Kf_Mat(obj,A,X,HyperPara2);
            % 转换为对称正定
            [Kf,d,V] = ConvertSymmetricalMatrixtoSemiPositive(Kf,0.01); % d特征向量, Kf*V = V*diag(d);
            % 似然函数
            % （备注：Kf\y有时候由于误差算不出来，导致结果为Nan）
            % a. 计算logdetKf的几种方法
            if ~matlab.addons.isAddonEnabled("Safe computation of logarithm-determinat of large matrix")
                % 必须安装此扩展
                error("This Add-On is required: Safe computation of logarithm-determinat of large matrix");
            end
            logdetKf = logdet(Kf); 
            % logdetKf = log(abs(prod(d))); % 特征值的乘积等于行列式
            % b. 计算f的几种方法
            f = - 0.5.*y'*(Kf\y) - 0.5*logdetKf - numel(y)/2*log(2*pi);
            % f = - 0.5.*(V*y)'*diag(1./d)*(V*y) - 0.5*logdetKf - numel(y)/2*log(2*pi);
        end
        
        function K = Kf_Mat(obj,A,X,HyperPara2)
            % 根据超参数矩阵[l,alpha; ...], 计算协方差矩阵 Kf
            % Kf为 [f1(x1),f1(x2), ..., f1(xn), f2(x1),f2(x2), ..., f2(xn), ...]
            %   X [f1(x1),f1(x2), ..., f1(xn), f2(x1),f2(x2), ..., f2(xn), ...]
            %   的协方差矩阵 
            Do = size(A,1);
            n = size(X,2);
            K = zeros(Do*n);
            for i=1:obj.Q
                K = K + kron(GPR_Stationary_SLFM.Bi(A,i), ...
                    Kf_Mat0(obj,X,[1,HyperPara2(i,:)]));
            end

        end
        
        function K = Kf_Mat0(obj,X,HyperPara)
            % 根据超参数向量[sigmaf,l,alpha], 计算协方差矩阵 Kf
            % X 为 D x n，D维输入列向量，n个观测值的坐标
            n = size(X,2);
            
            K_vec = obj.Kf_single(repmat(X,1,n),repelem(X,1,n),HyperPara);
            K = reshape(K_vec,n,n);

            % K = zeros(n,n);
            % for i=1:size(X,2)
            %     for j=i:size(X,2)
            %         K(i,j) = obj.Kf_single(X(:,i),X(:,j),HyperPara);
            %         K(j,i) = K(i,j);
            %     end
            % end
        end
        
        function K = Kf_single(obj,x1,x2,HyperPara)
            % 根据超参数向量[sigmaf,l,alpha], 计算单个协方差
            % x1, x2 为 D x n，D维输入列向量，n个观测值的坐标
            KernelF = str2func(['GPR_Stationary_SLFM.', ...
                obj.KernelTypeList{obj.KernelType}]);
            K = KernelF(vecnorm(x1-x2),HyperPara);
        end
    end
    
    methods (Static)
        function B = Bi(A,i)
            % B = A(:,i)*A(:,i)'
            B = A(:,i)*A(:,i)';
        end
        
        function y = exponential(x,Para)
            y = Para(1)^2 .* exp(-abs(x) ./Para(2));
        end
        
        function y = squaredexponential(x,Para)
            y = Para(1)^2 .* exp(-0.5.*x.^2 ./Para(2)^2);
        end
        
        function y = squaredexponential_plus_constant(x,Para)
            % Para [SigmaF, l, C]
            y = (Para(1)^2-Para(3)) .* exp(-0.5.*x.^2 ./Para(2)^2) ...
                + Para(3);
        end
        
        function y = exponential_plus_constant(x,Para)
            % para [sigmaf,l,C]
            y = (Para(1)^2 - Para(3)).* exp(-abs(x) ./Para(2)) + Para(3);
        end
        
        function y = RationalQuadratic_plus_constant(x,Para)
            % para [sigmaf,l,alpha,C]
            y = (Para(1)^2 - Para(4)) .*(1+x.^2./2./Para(3)./Para(2)^2).^(-Para(3)) ...
                + Para(4);
        end
        
        function y = RationalQuadratic(x,Para)
            % para [sigmaf,l,alpha]
            y = Para(1)^2.*(1+x.^2./2./Para(3)./Para(2)^2).^(-Para(3));
        end
    end
end

function [c,ceq] = Qnonlcon(x,Do,Q)
% A每一行的平方和等于1
% 
% 输入：
% x - 向量，Do*obj.Q+obj.Q*N_para，前Do*obj.Q项构成矩阵A
% Q - 高斯场Q维度
% Do - 输出维度
A = reshape(x(1:Do*Q),Do,Q);
ceq = vecnorm(A,2,2)-ones(Do,1);
c = [];
end

