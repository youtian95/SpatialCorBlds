classdef HazardCurve < handle
    % ����С�����𡢴�����ϵ���Σ��������&һ��Σ����(�淶��Ӧ�׵���״)
    %
    % ��1��ֻ��С��ʹ���ʱ���������Ϊ ln(lamda) = a+b*Sa �� lamda = a*Sa^(-b)
    %
    % ��2����С�����𡢴���ʱ���������Ϊ˫������, ����С�����𡢴���ĵ�
    %       ������С�������, ��Ϻ���Ϊ ln(lamda) = ln(k1)+k2/(ln(IM)-ln(k3)); 
    %    Bradley BA, Dhakal RP, Cubrinovski M, Mander JB, MacRae GA. 
    %       Improved seismic hazard model with application to probabilistic 
    %       seismic demand analysis. Earthquake Eng Struc. 2007;36:2211-25. 
    
    properties (SetAccess=protected)
        T
        alpha           %alpha�������Ӵ�С
        returnPeriod    %�ع���������
        Tg
        xi
    end
    
    % ��2�������еĲ���
    properties (Access=protected)
        k_para
        FirstTime = true   % �Ƿ��һ������
    end
    
    methods
        function obj = HazardCurve(T,alpha,returnPeriod,Tg,xi)
            %��¼
            obj.T=T;
            obj.alpha=alpha;
            obj.returnPeriod=returnPeriod;
            obj.Tg=Tg;
            obj.xi=xi;
        end
        
        %��ѯ����Σ�������ߵ�ֵ�ĺ���
        function lamda=getlamda(obj,Sa)
            if numel(obj.alpha)==2
                lamda=obj.getlamda2(Sa);
            elseif numel(obj.alpha)==3
                lamda=obj.getlamda3(Sa);
            end
        end
        %���ɵ���Σ�������ߵ�����
        function lamda=Createlamda(obj,Sa1,Sa2)
            lamda(1,:)=Sa1:0.01:Sa2;
            lamda(2,:)=obj.getlamda(lamda(1,:));
        end
        %���Ƶ���Σ��������
        function plotHazardCurve(obj,SaMin,SaMax)
            Sa=SaMin:0.01:SaMax;
            lamda=obj.getlamda(Sa);
            loglog(Sa,lamda);
            hold on;
            Sa_ = [];
            for i=1:numel(obj.alpha)
                Sa_ = [Sa_;obj.CreateASpectra(obj.T,obj.alpha(i),obj.Tg,obj.xi)];
            end
            scatter(Sa_,1./obj.returnPeriod);
        end
        %����һ��Σ��������
        function UHS=CreateUHS(obj,Sa1,Sa2,n)
            UHS(1,:)=0:0.01:6; %��һ������
            %n���Ҷ�
            for i=1:n
                %i�Ҷȴ�С
                SaT=Sa1+(Sa2-Sa1)/n/2+(Sa2-Sa1)/n*(i-1); 
                %����i�Ҷȵ�Σ����
                j=1;
                for tempT=0:0.01:6
                    amp=SaT./obj.CreateASpectra(obj.T,obj.alpha(1),obj.Tg,obj.xi); %����ϵ��
                    S(j)=obj.CreateASpectra(tempT,obj.alpha(1).*amp,obj.Tg,obj.xi); %i�Ҷȵ�Σ����ֵ
                    j=j+1;
                end
                UHS(i+1,:)=S;
            end
        end
        %����һ��Σ����
        function plotUHS(obj,Sa1,Sa2,n)
            UHS=obj.CreateUHS(Sa1,Sa2,n);
            hold on;
            for i=1:n
                plot(UHS(1,:),UHS(i+1,:));
            end
        end
    end
    
    methods (Access=protected)
        % ֻ��С��ʹ���ʱ��lamda�������
        function lamda=getlamda2(obj,Sa)
            % �������Ϊ ln(lamda) = a+b*ln(Sa)
            lamda1=1/obj.returnPeriod(1);
            lamda2=1/obj.returnPeriod(2);
            Sa1=obj.CreateASpectra(obj.T,obj.alpha(1),obj.Tg,obj.xi);
            Sa2=obj.CreateASpectra(obj.T,obj.alpha(2),obj.Tg,obj.xi);
            k2=-log(lamda1/lamda2)/log(Sa1/Sa2);
            k1=Sa1^k2*lamda1;
            lamda=k1.*Sa.^(-k2);
        end
        function lamda=getlamda2_(obj,Sa_in)
            % �������Ϊ ln(lamda) = a+b*Sa
            %   left_vec = right_A*[a;b]
            left_vec = log(1./obj.returnPeriod)';
            Sa = [];
            for i=1:numel(obj.alpha)
                Sa = [Sa;obj.CreateASpectra(obj.T,obj.alpha(i),obj.Tg,obj.xi)];
            end
            right_A = [ones(2,1),Sa];
            Para = right_A\left_vec;
            lamda = exp([ones(numel(Sa_in),1),Sa_in']*Para)';
        end
        % С�����𡢴���ʱ��lamda�������
        function lamda=getlamda3(obj,Sa_in)
            % �������Ϊ ln(lamda) = ln(k1)+k2/(ln(IM)-ln(k3))
            F = @(k,IM) log(k(1))+k(2)./(log(IM)-log(k(3)));
            if obj.FirstTime
                lamda_vec=1./obj.returnPeriod;
                Sa1_vec = [];
                for i=1:numel(lamda_vec)
                    Sa1_vec=[Sa1_vec, ...
                        obj.CreateASpectra(obj.T,obj.alpha(i),obj.Tg,obj.xi)];
                end
                % ��С���˷�
                k0 = [100 50 20]; %��ʼ����
                options = optimoptions('lsqcurvefit','MaxFunctionEvaluations',500*numel(lamda_vec));
                [obj.k_para,resnorm,~,exitflag,output] = lsqcurvefit(F,k0,Sa1_vec,log(lamda_vec),[],[],options);
                obj.FirstTime=false;
            end
            % ���
            lamda=exp(F(obj.k_para,Sa_in));
        end
    end
    
    methods (Static)
        function alpha=CreateASpectra(T,alphaMax,Tg,xi)
            % ���ɼ��ٶȷ�Ӧ��
            %����
            gamma=0.9+(0.05-xi)/(0.5+5*xi);
            eta1=max((0.02+(0.05-xi)/8),0);
            eta2=max((1+(0.05-xi)/(0.06+1.7*xi)),0.55);
            %��Ӧ��
            if T>=0 && T<0.1
                %������
                alpha=(0.45./eta2+10.*(1-0.45./eta2).*T).*eta2.*alphaMax;
            elseif T>=0.1 && T<=Tg
                %ˮƽ��
                alpha=eta2.*alphaMax;
            elseif T>Tg && T<=5*Tg
                %�½���
                alpha=(Tg./T).^(gamma).*eta2.*alphaMax;
            elseif T>5*Tg && T<=6.0
                %��б��
                alpha=(0.2^gamma-eta1/eta2.*(T-5*Tg)).*eta2.*alphaMax;
            else
                error('����T��Χ����');
            end
        end
    end
end

