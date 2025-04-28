pro Attempt_pick_up_wave

  probe='b' ;范艾伦双星的a,b
  trange=['2012-09-08','2012-10-10']  ;时间范围
  cdf_leap_second_init,/no_update
  time=time_intervals(trange=trange,tformat='YYYYMMDD')
  dens_filedir='E:\emfisis\Flight\RBSP-'+probe+'\L4\'+file_dailynames(trange=trange,file_format='YYYY\MM\DD\')
  n=n_elements(time)
  ;n1=0
  ;B=0
  ;E=0
  
  for i=0,n-1 do begin ;以天为单位循环
    timespan,time[i],1,/day
    den_filename=file_search(dens_filedir[i]+'rbsp-*density_emfisis*.cdf',count=c1);查找文件是否存在
    if c1 ge 1 then begin  ;ge为大于 大于1则存在
      wave_filename=file_search('E:\svd_emfisis\rbsp-'+probe+'_svd_emfisis_'+time[i]+'.tplot',count=c2);查找是否存在波数据
      if c2 ge 1 then begin ;ge为大于 大于1则存在
        del_data,'*'
        field_filename=file_search('E:\orbit\rbsp'+probe+'_orbit_'+time[i]+'.tplot',count=c3)
        tplot_restore,filenames=wave_filename ;tplot_restore为数据获取函数
        tplot_rename,'Epsd','Epsd2d'    
        tplot_restore,filenames=field_filename
        omni_load_data,varformat='AE_INDEX'  ;亚暴指数，表征磁暴强度
        cdf2tplot,den_filename,varformat='density'
        tplot_force_monotonic,'*',/forward
        
        get_data,'Epsd2d',t,Epsd ;波的电场数据，横坐标为时间，得到二维分布图像
        get_data,'Bpsd',t,Bpsd,fre ;波的磁场数据，频率
        get_data,'plan',t,plan ;平面度
        get_data,'ellip',t,ellip ;极化率
        ;get_data,'theta',t,theta
        ;get_data,'th_poy',t,th_poy
        Epsd=real_part(Epsd)
 
        tdegap,'density'  ;补插值，使变成时间间隔相等规律的数据，一一对应的点（因为测量仪器不同，时间间隔不同，要让电子数据在波的时间维度上插值）
        tinterpol_mxn,'density_degap',t,/nan_extrapolate ;电子密度
        tinterpol_mxn,'fce',t ;电子回旋频率
        tinterpol_mxn,'equator_fce',t ;赤道电子回旋频率
        tinterpol_mxn,'lshell',t ;磁壳数
        tinterpol_mxn,'mlt',t,/nearest_neighbor ;地方时
        ;tinterpol_mxn,'mlat',t
        ;tinterpol_mxn,'deviated_mlat',t
        tinterpol_mxn,'OMNI_HRO_1min_AE_INDEX',t,/nearest_neighbor ;亚暴指数
        calc,'"thresh_dens"=124.0*(3.0/"lshell_interp")^4.0'  ;合声波密度临界值（统计值），由于合声波分布在等离子层外，电子密度相对较低，考虑小于临界值
        get_data,'density_degap_interp',t,dens ;新生成的插值后的数据
        get_data,'fce_interp',t,fce
        get_data,'equator_fce_interp',t,equator_fce
        get_data,'lshell_interp',t,L
        get_data,'mlt_interp',t,MLT
        ;get_data,'mlat_interp',t,MLAT
        ;get_data,'deviated_mlat_interp',t,deviated_MLAT
        get_data,'OMNI_HRO_1min_AE_INDEX_interp',t,AE
        get_data,'thresh_dens',t,thresh_dens

       n=n_elements(AE) ;mlt等皆可
       if n ne 1 then begin ;对n筛选
         id1=where(finite(dens) and dens[0] ne 0 and dens le thresh_dens,c4)
           if c4 ge 1 then begin ;除去不符合要求的点
            for j=0,c4-1 do begin
              id2=where(fre ge 0.05*equator_fce[id1[j]] and fre le 0.5*equator_fce[id1[j]] and Bpsd[id1[j],*] ge 1e-9 and plan[id1[j],*] ge 0.5 and ellip[id1[j],*] ge 0.7,c5)
              ;只考虑下波段fre B太小可能为噪音
              if c5 ge 3 then begin ;存储数据
               append_array,AE0,AE[id1[j]]
               append_array,fce0,fce[id1[j]]
               append_array,L0,L[id1[j]]
               append_array,MLT0,MLT[id1[j]]
               append_array,dens0,dens[id1[j]]
               append_array,Bw0,sqrt(trapz_int(fre,Bpsd[id1[j],id2],/sort))*1000.0 ;波振幅
               ;B0=mean(Bpsd[id1[j],id2])
               ;E0=mean(Epsd[id1[j],id2])
               ;B=B+B0
               ;E=E+E0
               ;n1=n1+1
              endif       
            endfor
           endif 
         endif
      endif
    endif
  endfor
  save,AE0,fce0,L0,MLT0,dens0,Bw0,filename='E:\test\rbsp'+probe+'_picked_up_chorus_test_3' ;随时间的一维数组
  stop
end

