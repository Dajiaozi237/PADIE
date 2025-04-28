%----------------将所需文件导入到该路径下-----------------------------
code_dir='D:\research\';
addpath([code_dir 'Draw_Toolkit'])
addpath([code_dir 'irfu-matlab-master/irf'])
addpath([code_dir 'Restore_IDL/restore_idl']) 
%----------------设置绘图参数------------------------------------------
%%
figure(1);
fontsize=10; %字体大小
options.left=0.06; %option结构体 存储图像四个端的位置
options.right=0.97;
options.low=0.03;
options.high=0.84;
options.xgap=0.06; %左右两个图像的位置
options.ygap=0.06; %上下两个图像的位置   
r = (1:0.25:6)';
theta = 360*(0:24)/24;
xps = [-6.0,6.0,0,0]; 
yps = [0,0,6.6,-6.6]; %图像上二维圆上点所对应位置
texts = {'12     ','     00','06','18'};
linewidth = 1.5;
colormap(jet)
%----------------读取数据----------------------------------------------
wmode='chorus';
d = restore_idl([ 'C:\Users\DELL\Desktop\wyj\rbsp_bined_chorus_l-mlt_plane_Bw']);
tresh_num=100; %采样点限制 大于100
fpe2fce0=d.FPE2FCE_AVGS;
Bin_hist0=d.FPE2FCE_BINHIST;
Bw0=d.BW_AVGS;%振幅
%------------------循环画图------------------------------------------
for i=1:3
    switch(i)
        case 1
            titles='\bfAE < 100 nT\rm';
        case 2
            titles='\bf100 < AE < 500 nT\rm';
        case 3
            titles='\bfAE > 500 nT\rm';
    end
    Bin_hist=double(squeeze(Bin_hist0(i,:,:))); %i对应不同地磁活动强度
    fpe2fce=double(squeeze(fpe2fce0(i,:,:)));%squeeze扩充数组
    Bw=double(squeeze(Bw0(i,:,:)));
    Bw(Bin_hist<tresh_num)=NaN;
    fpe2fce(Bin_hist<tresh_num)=NaN;
    Bin_hist(Bin_hist<tresh_num)=NaN;  
    for j=1:3
        switch(j)
            case 1
                data=log10(Bin_hist);        
                cblabel='\bf# of Samples\rm';
                cmin=1; cstep=1; cmax=5;   %参数范围  
            case 2
                data=log10(Bw);
                cblabel='\bfB_w [pT]\rm';
                cmin=0; cstep=1; cmax=2;
            case 3
                data=(fpe2fce);
                cblabel='\bf\itf_{pe} / f_{ce}\rm';
                switch(wmode)
                    case 'chorus'
                        cmin=0; cstep=2; cmax=8; %等离子层外，等离子体密度低
                    case 'hiss'
                        cmin=0; cstep=5; cmax=20;
                    otherwise
                        error('Unknown wave mode "%s"',wmodel);
                end
            otherwise
                error('Unknown Dxx')
        end
        ax(i,j)=my_subplot(3,3,3*(i-1)+j,options);  %i、j在哪个位置画图
        
        set(ax(i,j),'xlim',[-6,6],'xtick',-6:2:6,'ylim',[-6,6],'ytick',-6:2:6,'linewidth',1,'ticklength',[0.02,0.03])  %设置绘图参数
        
        text(xps,yps,texts,'horizontalalignment','center','fontsize',fontsize)
        
        [h,~,~]=pieplot(r,theta,data,'zscale','linear','no_color_scale',1,'crange',[cmin,cmax],'no_create_axis',0,'linewidth',linewidth);
        %填色
        
        caxis([cmin,cmax]) 
        
        if j==1, text(-10,0,titles,'fontsize',12,'horizontalalignment','center','rotation',90); end %标题

        if i==1 %色板
            posax=ax(i,j).Position;
            cb=colorbar('northoutside'); %色板指数传递
            cb.TickLength=0.02; %线长
            cb.FontSize=7;
            cb.LineWidth=1;       cb.Position=[posax(1)+0.1*posax(3) posax(2)+1.15*posax(4) 0.8*posax(3) 0.08*posax(4)]; %色标左端右端上端下端宽度长度
            cb.Ticks=cmin:cstep:cmax;
            if j~=3;cb.TickLabels=arrayfun(@(i)['10^{' num2str(i) '}'],cmin:cstep:cmax,'un',false); end
            ylabel(cb,cblabel)
        end
    end
end
irf_pl_number_subplots([ax(:,1),ax(:,2),ax(:,3)],[-0.001,1.001],'color','black','fontsize',15) %标序号
