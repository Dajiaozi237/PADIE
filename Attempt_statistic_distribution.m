%----------------将所需文件导入到该路径下-----------------------------
clear,clf
addpath(['D:\research\Radiatin_Belt_Modeling\opendc'])
addpath(['D:\research\Radiatin_Belt_Modeling\DC_code'])
addpath(['D:\research\Restore_IDL\restore_idl'])
%%
%----------------读取文件，并设置参数-------------------------------
species='e'; %作用对象为电子
a1=70;  %设定投掷角 0,89,5  
kev=2000; %100-2000kev 对数间隔，10
d=restore_idl(['C:\Users\DELL\Desktop\wyj\rbsp_bined_chorus_l-mlt_plane_Bw']);
L0=double(d.BW_XCS); %20个L
MLT=double(d.BW_YCS); %0-24MLT有24个点
core_number = 4;
parpool(core_number) ;
pctRunOnAll
%----------------计算Daa，Dpp（投掷角为10°、70°）-----------------------------
  for i=1:3 %对AE循环
    id1=find(L0 > 2)  %不考虑L<2的区域
    for j=id1(1):20 %20 L
        L=L0(j);
        parfor k=1:24 %MLT
            fpe2fce=double(squeeze(d.FPE2FCE_AVGS(i,j,k)));  %squeeze:删除长度为1的维度
            wave_model = struct();
            wave_model.omega_pe = fpe2fce;  
            wave_model.Bw = 0.01;%为了计算方便
            wave_model.normalization = 'Omega_e_eq';
            wave_model.omega_pe_normalization = 'Omega_e_eq'
            if MLT(k)>=18 || MLT(k)<6 %夜侧
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
               wave_model.omega_uc = 0.4; %前人统计结果 波的特征
            end
            wave_model.theta_m = @(L,maglat)0;  %X分布的峰值
            wave_model.theta_w = @(L,maglat)30; %X分布的半宽度
            wave_model.theta_min = @(L,maglat)0; %X分布的下限
            wave_model.theta_max = @(L,maglat)45;  %X分布的上限
            
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

            
            
            
            
            
        






