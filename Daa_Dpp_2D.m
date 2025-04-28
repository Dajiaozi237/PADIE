%----------------将所需文件导入到该路径下-----------------------------
code_dir='D:\research\';
addpath([code_dir 'Draw_Toolkit'])
addpath([code_dir 'irfu-matlab-master/irf'])
addpath([code_dir 'Restore_IDL/restore_idl']) 
%----------------设置绘图参数------------------------------------------
%%
figure(1);
fontsize=10;
options.left=0.06;
options.right=0.82;
options.low=0.03;
options.high=0.9;
options.xgap=0.06;
options.ygap=0.04;     
r = (1:0.25:6)';
theta = 360*(0:24)/24;
xps = [-6.0,6.0,0,0];
yps = [0,0,6.6,-6.6];
texts = {'12     ','     00','06','18'};
linewidth = 1.5;
colormap(jet)
%----------------读取数据----------------------------------------------
wmode='chorus';
d = restore_idl([ 'C:\Users\DELL\Desktop\wyj\rbsp_bined_chorus_l-mlt_plane_Bw']);
tresh_num=100;
fpe2fce0=d.FPE2FCE_AVGS;
Bin_hist0=d.FPE2FCE_BINHIST;
Bw0=d.BW_AVGS;
load('C:\Users\DELL\Desktop\wyj\Dxx_chorus_70_200keVdeg');
Dpp0=Dpp;
load('C:\Users\DELL\Desktop\wyj\Dxx_chorus_70_700keVdeg');
Dpp1=Dpp;
load('C:\Users\DELL\Desktop\wyj\Dxx_chorus_70_1000keVdeg');
Dpp2=Dpp;
load('C:\Users\DELL\Desktop\wyj\Dxx_chorus_70_2000keVdeg');
Dpp3=Dpp;
%------------------循环画图------------------------------------------
for i=1:3 %三个AE
    switch(i)
        case 1
            titles='\bfAE < 100 nT\rm';
        case 2
            titles='\bf100 < AE < 500 nT\rm';
        case 3
            titles='\bfAE > 500 nT\rm';
    end
    Bw=double(squeeze(Bw0(i,:,:)));
    Dpp4=squeeze(Dpp(i,:,:));
    Dpp5=squeeze(Dpp(i,:,:));
    Dpp6=squeeze(Dpp(i,:,:));
    Dpp7=squeeze(Dpp(i,:,:));
    Bw(Bin_hist<tresh_num)=NaN;
    fpe2fce(Bin_hist<tresh_num)=NaN;
    Bin_hist(Bin_hist<tresh_num)=NaN;
    Dpp4=((Bw./10).^2).*squeeze(Dpp0(i,:,:)); %与振幅平方成正比
    Dpp4(Bin_hist<tresh_num)=NaN;
    Dpp5=((Bw./10).^2).*squeeze(Dpp1(i,:,:));
    Dpp5(Bin_hist<tresh_num)=NaN; 
    Dpp6=((Bw./10).^2).*squeeze(Dpp2(i,:,:));
    Dpp6(Bin_hist<tresh_num)=NaN; 
    Dpp7=((Bw./10).^2).*squeeze(Dpp3(i,:,:));
    Dpp7(Bin_hist<tresh_num)=NaN; 
    for j=1:4 %划分Daa和Dpp
        switch (j)
            case 1
                data=log10(Dpp4*3600);  %为什么要×3600 s化为h s太小
                cdlabel='\bf E=200kev \rm';
                cmin=-6; cstep=1; cmax=0;
            case 2
                data=log10(Dpp5*3600);  %为什么要×3600 s化为h s太小
                cdlabel='\bf E=700kev \rm';
                cmin=-6; cstep=1; cmax=0;
            case 3
                data=log10(Dpp6*3600);  %为什么要×3600 s化为h s太小
                cdlabel='\bf E=1000kev \rm';
                cmin=-6; cstep=1; cmax=0;
            case 4
                data=log10(Dpp7*3600);  %为什么要×3600 s化为h s太小
                cdlabel='\bf E=2000kev \rm';
                cmin=-6; cstep=1; cmax=0;
          
            otherwise
                error('Unknown Dxx')
        end
        ax(i,j)=my_subplot(4,3,3*(j-1)+i,options);  %自己定义的函数 行、列、第几个位置开始画图、参数
        
        set(ax(i,j),'xlim',[-6,6],'xtick',-6:2:6,'ylim',[-6,6],'ytick',-6:2:6,'linewidth',1,'ticklength',[0.02,0.03])  %设置绘图参数
        
        text(xps,yps,texts,'horizontalalignment','center','fontsize',fontsize)
        
        [h,~,~]=pieplot(r,theta,data,'zscale','linear','no_color_scale',1,'crange',[cmin,cmax],'no_create_axis',0,'linewidth',linewidth);%填充颜色
        
        caxis([cmin,cmax])  
        
        if j==1, text(0,10,titles,'fontsize',17,'horizontalalignment','center'); end
        
        if i==3&&j==4
            posax=ax(i,j).Position;
            cblabel='\bf<\itD_{pp}\rm\bf>\it / p\rm\bf^2  [h^{-1}]\rm';
            %cblabel='\bf<\itD_{\alpha\alpha}\rm\bf>\it / p\rm\bf^2  [h^{-1}]\rm';
            cb=colorbar('eastoutside');
            cb.TickLength=0.04;
            cb.FontSize=10;
            cb.LineWidth=1;%厚度
            cb.Position=[posax(1)+1.1*posax(3) posax(2)+0.24*posax(4) 0.1*posax(3) 1.5*posax(4)];
            cb.Ticks=cmin:cstep:cmax;
            cb.TickLabels=arrayfun(@(i)['10^{' num2str(i) '}'],cmin:cstep:cmax,'un',false); 
            ylabel(cb,cblabel)
        end
        if i==1, text(-10,0,cdlabel,'fontsize',12,'horizontalalignment','center','rotation',90); end %标题
        
    end
end

irf_pl_number_subplots([ax(:,1),ax(:,2),ax(:,3),ax(:,4)],[-0.001,1.001],'color','black','fontsize',16)
