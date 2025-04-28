%%
clear,clf
addpath(['D:\research\Radiatin_Belt_Modeling\opendc'])
addpath(['D:\research\Radiatin_Belt_Modeling\DC_code'])
addpath(['D:\research\Restore_IDL\restore_idl'])
code_dir='D:\research\';
addpath([code_dir 'Draw_Toolkit'])
addpath([code_dir 'irfu-matlab-master/irf'])
addpath([code_dir 'Restore_IDL/restore_idl'])
%%
fontsize=22;
options.left=0.15;
options.right=0.8;
options.low=0.1;
options.high=0.95;
options.xgap=0.017;
options.ygap=0.025;
aeq=2:4:89;  
%a_interp=2:0.5:89;
KeV=logspace(log10(50),log10(2e3),10);
tresh_number = 50; %没有统计意义的点剔除
util = odc_util;
d = restore_idl(['C:\Users\DELL\Desktop\wyj\rbsp_bined_chorus_l-mlt_plane_Bw']);
Ls=double(d.BW_XCS);
Chorus_BINHIST=double(d.BW_BINHIST); %没有统计意义的点剔除
Chorus_BW_AVGS=double(d.BW_AVGS);
Chorus_BW_AVGS(isnan(Chorus_BW_AVGS)) = 0;
load(['C:\Users\DELL\Desktop\wyj\Dxx_chorus'])
Daa0=Daa;
Daa0(isnan(Daa0) | Chorus_BINHIST<tresh_number)=0;
load(['C:\Users\DELL\Desktop\wyj\Dxx_chorus'])
Dpp0=Dpp;
Dpp0(isnan(Dpp0) | Chorus_BINHIST<tresh_number)=0;  %MLT平均
for a=1:22 %22个电荷
    for e=1:10 %能量
        Daa1(:,:,:,e,a)=Daa0(:,:,:,e,a).*((Chorus_BW_AVGS./10).^2)*3600;
        Dpp1(:,:,:,e,a)=Dpp0(:,:,:,e,a).*((Chorus_BW_AVGS./10).^2)*3600;
    end
end
Daa2=squeeze(mean(Daa1(:,[9 13 17 20],:,:,:),3)); %第三维做平均 MLT 漂移平均（电子绕地球做漂移运动）
Dpp2=squeeze(mean(Dpp1(:,[9 13 17 20],:,:,:),3));
Daa3=permute(Daa2,[3,4,1,2]);
Dpp3=permute(Dpp2,[3,4,1,2]); %转置
colormap jet;
on=2; %1 for Daa;2 for Dpp
if on ==2
    for i=1:4 %对L做循环
        for j=1:3
            ax(i,j)=my_subplot(4,3,3*(i-1)+j,options);  
            [Y,X]=meshgrid(aeq,KeV);%KeV 22 aeq 10
            [Y1,X1]=meshgrid(2:4:86,50:25:2000);
            d1=griddata(Y,X,log10(squeeze(Dpp3(:,:,j,i))),Y1,X1); %Dpp3=10 22 3 4
            s=pcolor(Y1,X1,d1);    
            s.EdgeColor ='none'; %小方块填色
            set(gca,'yscale','log','fontsize',14) %gca理解为指针
            axis([0,90,50,2000]); %横坐标0-90 纵坐标50-2000
            %caxis([-4,0]); %log
            %cmin=-4; cstep=1; cmax=0;
            caxis([-7,-1]);
            cmin=-7; cstep=1; cmax=-1;
            if j==1
                switch(i)
                    case 1
                        ylabel({'\bfL=3';'\bf E (keV)'},'Fontsize',13);
                    case 2
                        ylabel({'\bfL=4';'\bf E (keV)'},'Fontsize',13);
                    case 3
                        ylabel({'\bfL=5';'\bf E (keV)'},'Fontsize',13);
                    case 4
                        ylabel({'\bfL=6';'\bf E (keV)'},'Fontsize',13);
                end                       
            end  
            if j~=1;set(gca,'YTickLabel',' '); end
            if i==4;xlabel('\bf \alpha_e_q (°)','Fontsize',10);end
            if i~=4;set(gca,'XTickLabel',' ');end
            set(gca,'Layer','top','fontsize',13,'ticklength',[0.012,0.012],'xminortick','on','xlim',[0,88],'ylim',[50,2000],'Ytick',[100,1000])
            set(ax(i,j),'xtick',[0 20 40 60 80],'linewidth',0.8,'ticklength',[0.02,0.03]) 
            if i==1
                switch(j)
                    case 1
                        title('AE<100nT','fontsize',15,'FontWeight','bold')
                    case 2
                        title('100<AE<500nT','fontsize',15,'FontWeight','bold')
                    case 3
                        title('AE>500nT','fontsize',15,'FontWeight','bold')
                end
            end
            
            if i==4 && j==3
                posax=ax(4,3).Position;
                cb=colorbar('eastoutside');
                cb.TickLength=0.02;
                cb.FontSize=12;
                cb.LineWidth=1;
                cb.Position=[0.82 0.1 0.022 0.85];
                %cb.Ticks=[-4 -3 -2 -1 0]
                cb.Ticks=[-7 -6 -5 -4 -3 -2 -1]
                cb.TickLabels=arrayfun(@(i)['10^{' num2str(i) '}'],cmin:cstep:cmax,'un',false)
                %cblabel='\bf(<\itD_{\alpha\alpha}\rm\bf>\it / p\rm\bf^2  [h^{-1}])\rm';
                cblabel='\bf(<\itD_{pp}\rm\bf>\it / p\rm\bf^2  [h^{-1}])\rm';
                ylabel(cb,cblabel,'fontsize',10)
            end
        end
    end
end

irf_pl_number_subplots([ax(1,:),ax(2,:),ax(3,:),ax(4,:)],[0.06,0.96],'color','k','fontsize',15)