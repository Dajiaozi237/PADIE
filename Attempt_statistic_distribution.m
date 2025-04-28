%----------------�������ļ����뵽��·����-----------------------------
clear,clf
addpath(['D:\research\Radiatin_Belt_Modeling\opendc'])
addpath(['D:\research\Radiatin_Belt_Modeling\DC_code'])
addpath(['D:\research\Restore_IDL\restore_idl'])
%%
%----------------��ȡ�ļ��������ò���-------------------------------
species='e'; %���ö���Ϊ����
a1=70;  %�趨Ͷ���� 0,89,5  
kev=2000; %100-2000kev ���������10
d=restore_idl(['C:\Users\DELL\Desktop\wyj\rbsp_bined_chorus_l-mlt_plane_Bw']);
L0=double(d.BW_XCS); %20��L
MLT=double(d.BW_YCS); %0-24MLT��24����
core_number = 4;
parpool(core_number) ;
pctRunOnAll
%----------------����Daa��Dpp��Ͷ����Ϊ10�㡢70�㣩-----------------------------
  for i=1:3 %��AEѭ��
    id1=find(L0 > 2)  %������L<2������
    for j=id1(1):20 %20 L
        L=L0(j);
        parfor k=1:24 %MLT
            fpe2fce=double(squeeze(d.FPE2FCE_AVGS(i,j,k)));  %squeeze:ɾ������Ϊ1��ά��
            wave_model = struct();
            wave_model.omega_pe = fpe2fce;  
            wave_model.Bw = 0.01;%Ϊ�˼��㷽��
            wave_model.normalization = 'Omega_e_eq';
            wave_model.omega_pe_normalization = 'Omega_e_eq'
            if MLT(k)>=18 || MLT(k)<6 %ҹ��
               wave_model.lambda = 20; 
               wave_model.omega_m = 0.25;
               wave_model.domega = 0.175;
               wave_model.omega_lc = 0.05;
               wave_model.omega_uc = 0.5;
            else
               wave_model.lambda = 35;
               wave_model.omega_m = 0.2;
               wave_model.domega = 0.15;
               wave_model.omega_lc = 0.05;
               wave_model.omega_uc = 0.4; %ǰ��ͳ�ƽ�� ��������
            end
            wave_model.theta_m = @(L,maglat)0;  %X�ֲ��ķ�ֵ
            wave_model.theta_w = @(L,maglat)30; %X�ֲ��İ���
            wave_model.theta_min = @(L,maglat)0; %X�ֲ�������
            wave_model.theta_max = @(L,maglat)45;  %X�ֲ�������
            
            if isfinite(fpe2fce)
                [Daa0,~,Dpp0,~,~] = Daa_ba(species,L,kev,a1,wave_model);
            else
                Daa0=NaN;
                Dap0=NaN;
                Dpp0=NaN;
            end            
            Daa(i,j,k)=Daa0;
            %Dap(i,j,k)=Dap0;
            Dpp(i,j,k)=Dpp0;
        end
    end
  end
save([ 'C:\Users\DELL\Desktop\wyj\Dxx_chorus_70_2000kevdeg'],'Daa','Dpp')
delete(gcp('nocreate'))

            
            
            
            
            
        






