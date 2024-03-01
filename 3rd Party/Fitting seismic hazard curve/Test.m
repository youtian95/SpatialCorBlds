% ����
%
% ���� HazardCurve(T,alpha,returnPeriod,Tg,xi)
% ���룺
% T -�ṹ��������
% alpha -�����Ӵ�С���淶��alpha�����淶�����ƽ̨�ε��׼��ٶ�(��gΪ��λ)
% returnPeriod -��Ӧ�Ļع�����, �鿴����淶3.10.3����˵��
% Tg -�淶��Ӧ�׵�Tg
% xi -�����

% �Ϻ���7�ȣ�0.1g���ڶ���
T = 0.5;
alpha = [0.50,0.1,0.08]; 
returnPeriod = [1600,475,50]; %ע�⿹��淶3.10.3����˵�����Ϻ�7�ȴ���ع�����Ϊ1600
Tg = 0.6; xi = 0.05;
obj = HazardCurve(T,alpha,returnPeriod,Tg,xi);

% ��ʾ���
r = 1;
if r==1
    obj.plotHazardCurve(0.05,1); %��ʾ����Σ��������
    lamda=obj.Createlamda(0.05,4); %���ɵ���Σ�������ߵ�����
else 
    obj.plotUHS(0.05,1.0,8); %����һ��Σ����
    UHS=obj.CreateUHS(0.05,1.0,8); %����һ��Σ���׵�����
end
