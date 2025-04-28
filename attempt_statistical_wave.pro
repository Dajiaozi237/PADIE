pro attempt_statistical_wave
 flagnodata=!values.f_nan
 restore,filename='C:\Users\DELL\Desktop\wyj\rbspa_picked_up_chorus' ;restore读数据
 AE1=AE0
 L1=L0
 MLT1=MLT0
 fce1=fce0
 dens1=dens0
 Bw1=Bw0
 
 restore,filename='C:\Users\DELL\Desktop\wyj\rbspb_picked_up_chorus'
 append_array,AE1,AE0
 append_array,L1,L0
 append_array,MLT1,MLT0
 append_array,fce1,fce0
 append_array,dens1,dens0
 append_array,Bw1,Bw0
 

 
 fpe=9.0e3*sqrt(dens1) ;等离子体频率
 fpe2fce=fpe/fce1 ;等离子体频率/电子回旋频率
 
 AE=[[0,100],[100,500],[500,1e4]] ;地磁平静期，中等扰动期，地磁高扰动期
 
 Bw_avgs=make_array(3,20,24,value=!values.f_nan)  ;value=!values.f_nan
 Bw_meds=make_array(3,20,24,value=!values.f_nan)   ; 3对应AE,20对应L，分辨率0.25,24对应MLT,分辨率为1h
 Bw_binhist=make_array(3,20,24,value=!values.f_nan) ;binhist指存了多少个点
 fpe2fce_avgs=make_array(3,20,24,value=!values.f_nan)
 fpe2fce_meds=make_array(3,20,24,value=!values.f_nan)
 fpe2fce_binhist=make_array(3,20,24,value=!values.f_nan) 
 
 for i=0,2 do begin ;AE循环三次
  id1=where(AE1 ge AE[0,i] and AE1 lt AE[1,i] and finite(BW1)) 
  bin2d,L1[id1],MLT1[id1],Bw1[id1],binsize=[0.25,1],xrange=[1,6],yrange=[0,24],flagnodata=flagnodata,$
    averages=Bw_avgs0,medians=Bw_meds0,binhistogram=Bw_binhist0,xcenters=Bw_xcs,ycenters=Bw_ycs ;meds指平均，binsize指磁壳数和地方时的分辨率区间
    
  Bw_avgs[i,*,*]=Bw_avgs0
  Bw_meds[i,*,*]=Bw_meds0
  Bw_binhist[i,*,*]=Bw_binhist0 ;把二维数组传递到三维数组中，i为AE分类
  
  bin2d,L1[id1],MLT1[id1],fpe2fce[id1],binsize=[0.25,1],xrange=[1,6],yrange=[0,24],flagnodata=flagnodata,$
    averages=fpe2fce_avgs0,medians=fpe2fce_meds0,binhistogram=fpe2fce_binhist0,xcenters=fpe2fce_xcs,ycenters=fpe2fce_ycs
    
  fpe2fce_avgs[i,*,*]=fpe2fce_avgs0 
  fpe2fce_meds[i,*,*]=fpe2fce_meds0
  fpe2fce_binhist[i,*,*]=fpe2fce_binhist0
 endfor
 
 save,Bw_avgs,Bw_meds,Bw_binhist,Bw_xcs,Bw_ycs,$
   fpe2fce_avgs,fpe2fce_meds,fpe2fce_binhist,fpe2fce_xcs,fpe2fce_ycs,$
   filename='C:\Users\DELL\Desktop\Wangyijia\data\rbsp_bined_chorus_l-mlt_plane_Bw_test' ;默锟较憋拷锟斤拷为.SAV锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷娲�拷模锟斤拷锟�
 stop
 
end