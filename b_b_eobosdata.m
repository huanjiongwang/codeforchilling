                                                                                                function b_b_eobosdata()
%function: extract tem data from EOBS according to location PEP stations
%提取出对应的气象数据
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%users settings%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%users settings

station=dlmread('allstation_se.txt');   %inputdata: sttion information 【PEPID  LON LAT ALT】
filepath='G:\data\格网气候数据\E-obs\';   %inputdata: EOSdfile path
outpputfilepath=[cd '\temdata\'];   %outputpath

%output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%station_EOSposition.txt: show the position of PEP station in the EOS file
%daily temperature change file (e.g.489-293min) from 1950 to 2018


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
finfo = ncinfo([filepath  'rr_ens_spread_0.1deg_reg_v21.0e.nc']);
longitude  = ncread([filepath  'rr_ens_spread_0.1deg_reg_v21.0e.nc'],'longitude');
latitude  = ncread([filepath 'rr_ens_spread_0.1deg_reg_v21.0e.nc'],'latitude');
time  = ncread([filepath 'rr_ens_spread_0.1deg_reg_v21.0e.nc'],'time');


num=1;
for i=1:size(station,1)
    
    lon=station(i,2);
    lat=station(i,3);
    [M,lonnum] = min(abs(longitude-lon));
    [M,latnum] = min(abs(latitude-lat));
    allnum(num,1)=lonnum;
    allnum(num,2)=latnum;
    num=num+1;
   
end

dlmwrite([outpputfilepath 'station_EOSposition.txt'],[station   allnum]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%补充温度数据的年和DOY
   alldoy=[];
   for k=1950:2017
       if mod(k,4)==0
           thisyear=[k*ones(366,1) (1:366)'];
       else
           thisyear=[k*ones(365,1) (1:365)'];
       end
       alldoy=cat(1,alldoy,thisyear);
   end
   thisyear=[2018*ones(334,1) (1:334)'];
    alldoy=cat(1,alldoy,thisyear);
    
    dlmwrite([outpputfilepath 'alldoy.txt'],alldoy);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%输出降水
 [C,ia,ic] = unique(allnum,'rows');
 
 for i=1:size(C,1)
     i
     if exist([outpputfilepath num2str(C(i,1)) '-' num2str(C(i,2)) 'pre.txt'],'file')==0
           tic
             ardata10 = ncread([filepath 'rr_ens_spread_0.1deg_reg_v23.1e.nc'],'rr',[C(i,1) C(i,2) 1],[1 1 25171]);
           toc
             ardata20 = reshape(ardata10,[25171,1]);
              dlmwrite([outpputfilepath num2str(C(i,1)) '-' num2str(C(i,2)) 'pre.txt'],ardata20);

     end
 end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%输出温度

 [C,ia,ic] = unique(allnum,'rows');
 
 for i=1:size(C,1)
     i
     if exist([outpputfilepath num2str(C(i,1)) '-' num2str(C(i,2)) '.txt'],'file')==0
           tic
             ardata10 = ncread([filepath 'tg_ens_spread_0.1deg_reg_v23.1e.nc'],'tg',[C(i,1) C(i,2) 1],[1 1 25171]);
             ardata11 = ncread([filepath 'tn_ens_spread_0.1deg_reg_v23.1e.nc'],'tn',[C(i,1) C(i,2) 1],[1 1 25171]);
             ardata12 = ncread([filepath 'tx_ens_spread_0.1deg_reg_v23.1e.nc'],'tx',[C(i,1) C(i,2) 1],[1 1 25171]);
           toc
             ardata20 = reshape(ardata10,[25171,1]);
             ardata21 = reshape(ardata11,[25171,1]);
             ardata22 = reshape(ardata12,[25171,1]);
              dlmwrite([outpputfilepath num2str(C(i,1)) '-' num2str(C(i,2)) '.txt'],ardata20);
              dlmwrite([outpputfilepath num2str(C(i,1)) '-' num2str(C(i,2)) 'min.txt'],ardata21);
              dlmwrite([outpputfilepath num2str(C(i,1)) '-' num2str(C(i,2)) 'max.txt'],ardata22);
     end
 end








