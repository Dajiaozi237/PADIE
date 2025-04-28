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
options.left=0.08;%离左边距离
options.right=0.865;
options.low=0.35;
options.high=0.69;
options.xgap=0.017;
options.ygap=0.025;
colormap(jet);
%----------------读取数据----------------------------------------------
%%
aeq=2:4:80; %设定投掷角
L0=3:0.155:6;
KeV=logspace(log10(50),log10(2e4),10);
tresh_number=50;
util=odc_util;
d = restore_idl([ 'C:\Users\DELL\Desktop\wyj\rbsp_bined_chorus_l-mlt_plane_Bw']);
Ls=double(d.BW_XCS);
Chorus_BINHIST=double(d.BW_BINHIST); %没有统计意义的点剔除
Chorus_BW_AVGS=double(d.BW_AVGS);
Chorus_BW_AVGS(isnan(Chorus_BW_AVGS)) = 0;
load(['C:\Users\DELL\Desktop\wyj\Dxx_chorus'])
Daa(isnan(Daa) | Chorus_BINHIST<tresh_number)=0;
Dpp(isnan(Dpp) | Chorus_BINHIST<tresh_number)=0;  %MLT平均
for a=1:22
    for e=1:10
         Daa1(:,:,:,e,a)=Daa(:,:,:,e,a).*((Chorus_BW_AVGS./10).^2)*3600*24; %3600化成h,24化成day
        Dpp1(:,:,:,e,a)=Dpp(:,:,:,e,a).*((Chorus_BW_AVGS./10).^2)*3600*24;
    end
end%抽取数据
Daa2=squeeze(mean(Daa1,3)); %第三维做平均 MLT 漂移平均（电子绕地球做漂移运动）
Dpp2=squeeze(mean(Dpp1,3));
Daa3=permute(Daa2,[4,2,1,3]);
Dpp3=permute(Dpp2,[4,2,1,3]);%转置
for e=1:10 %能量
    Daa0=squeeze(Daa3(:,:,:,e));
    Dpp0=squeeze(Dpp3(:,:,:,e));%squeeze 扩充数组
    for i=1:3 %第一维循环 AE
        id=find(Ls>2);
        for j=id(1):20 %第二维循环 L
            L=Ls(j);
            a1=util.angle_loss_cone(L); %损失锥大小
            Daa_an=squeeze(Daa0(:,j,i));
            Dpp_an=squeeze(Dpp0(:,j,i));
            idl=find(aeq>=a1); %投掷角大于损失锥
            a0=aeq(idl);
            Daa_an2=Daa_an(idl);
            f=1./(2.*Daa_an2'.*tand(a0));
            lifetime(i,j,e)=trapz(deg2rad(a0),f); %弧度积分 3 20 10
            id2=find(aeq==70);
            timescale(i,j,e)=1/Dpp_an(id2);%3 20 10
        end
       
    end
end
%------------------循环画图------------------------------------------
 timescale=permute(timescale,[3,2,1,4]);% 10,20,3
 lifetime=permute(lifetime,[3,2,1,4]);
for j=1:3 %对L做循环
            i=1;
            ax(i,j)=my_subplot(1,3,3*(i-1)+j,options);  
            [Y,X]=meshgrid(L0,KeV);%KeV 22 aeq 10
            [Y1,X1]=meshgrid(3:0.155:6,50:25:10000);
            
            d1=griddata(Y,X,log10(squeeze(timescale(:,:,j))),Y1,X1); %
            s=pcolor(Y1,X1,d1);    
            s.EdgeColor ='none'; %小方块填色
            set(gca,'yscale','log','fontsize',14) %gca理解为指针
            axis([0,90,50,10000]); %横坐标0-20 纵坐标50-2000
            caxis([-1,4]); %log
            cmin=-1; cstep=1; cmax=4;
            
            if i==1
                switch(j)
                    case 1
                        ylabel({'E (keV)'},'Fontsize',18,'FontWeight','bold')
                end                       
            end  
            if j~=1;set(gca,'YTickLabel',' '); end
            if i==1;xlabel('\bf L','Fontsize',10);end
            if i~=1;set(gca,'XTickLabel',' ');end
            set(gca,'Layer','top','fontsize',13,'ticklength',[0.012,0.012],'xminortick','on','xlim',[3,6],'ylim',[50,10000],'Ytick',[100,1000,10000])
            set(ax(i,j),'xtick',[3,4,5,6],'linewidth',0.8,'ticklength',[0.02,0.02]) 
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
            
            if i==1 && j==3
                posax=ax(1,3).Position;
                cb=colorbar('eastoutside');
                cb.TickLength=0.02;
                cb.FontSize=10;
                cb.LineWidth=1;
                cb.Position=[0.88 0.356 0.02 0.335];%左右 上下 宽 长
                cb.Ticks=[-1 0 1 2 3 4];
               
                cb.TickLabels=arrayfun(@(i)['10^{' num2str(i) '}'],cmin:cstep:cmax,'un',false);
                cblabel='\bf\it Acceleration Timescale\rm\bf [day^{-1}]\rm';
                %cblabel='\bf\it Loss Timescale\rm\bf [day^{-1}]\rm';
                ylabel(cb,cblabel,'fontsize',8)
            end
 end
       

    