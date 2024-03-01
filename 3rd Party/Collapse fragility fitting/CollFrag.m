classdef CollFrag < handle
    %�����������,�����Ȼ����; ע��: ��Ҫ��װ Optimization Toolbox 
    %
    
    properties (SetAccess=protected)
        medianSa   %��ֵ
        sigmalnSa  %������׼��
    end
    properties (Access=protected)
        Sa   
        Pcon %�������ʹ۲�ֵ
    end
    
    methods
        function obj = CollFrag(Sa,Pcon)
            obj.Sa = Sa;
            obj.Pcon = Pcon;
            if norm(Pcon)==0
                obj.medianSa = inf; %�����
                obj.sigmalnSa = 0;
            else
                obj.CurveFit();
            end
        end
        function plotFit(obj)
            %���ֵ
            pd = makedist('Lognormal','mu',log(obj.medianSa),'sigma',obj.sigmalnSa); %������̬�ֲ�����
            x= exp(log(obj.medianSa)-3*obj.sigmalnSa):0.01:exp(log(obj.medianSa)+3*obj.sigmalnSa);
%             x=0:0.01:3.5;
            y = cdf(pd,x);
            plot(x,y); 
            %��ɢֵ
            hold on;
            scatter(obj.Sa,obj.Pcon);
        end
    end
    
    methods (Access=protected)
        function CurveFit(obj)
            %��Լ���������Ż�
            fun=@(x) -obj.SumofSquares(x(1),x(2)); %ʹ�������
            x0 = [0,1]; %��ʼֵ
            A = []; b = []; %���Բ���ʽԼ��
            Aeq = []; beq = [];%���Ե�ʽԼ��
            lb = [-inf,0]; ub = [inf,1]; %x��Χ
            result = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
            obj.medianSa=exp(result(1));
            obj.sigmalnSa=result(2);
        end
        
        function sumofR=SumofSquares(obj,mu,sigma)
            %�в�
            pd1 = makedist('Lognormal','mu',mu,'sigma',sigma); %������̬�ֲ�����
            y = cdf(pd1,obj.Sa);
            for i=1:size(obj.Sa,2)
                temp = makedist('Binomial','N',size(obj.Sa,2),'p',y(i));%����ֲ�
                pd2(i) = pdf(temp,int8(obj.Pcon(i)*size(obj.Sa,2)));   %����obj.Pcon(i)�εĸ���
            end
            sumofR=sum(log(pd2));
        end
    end
end

