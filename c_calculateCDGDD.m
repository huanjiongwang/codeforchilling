function c_calculateCDGDD()
%输出每个物种每年的GDD和CD
addpath([cd '\function\'])

%input
fileID = fopen('phenophase_se.txt');    %phenophase investigated (specie BBCHcode)
stationNUM=dlmread([cd '\temdata\station_EOSposition.txt']); %position of each station in the gridded tem data
outputpath=[cd '\CDGDDresults\'];
alldoy=dlmread([cd '\temdata\alldoy.txt']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[C1, ia, ic] = unique(stationNUM(:,1));
stationNUM=stationNUM(ia,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%读取物候期
C = textscan(fileID,'%s %s %f');
fclose(fileID);
genus_se=C{1};
species_se=C{2};
pheID_se=C{3};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%开始读取物候数据
for i=1:size(species_se,1)
    phedata2=dlmread([cd '\phedata\'  genus_se{i} ' ' species_se{i} ' ' num2str(pheID_se(i)) '_phe_se.dat']);        %所有的数据
    phedata2 = sortrows(phedata2,[1 2 3]);
    numofrecords_se(i,1)=pheID_se(i);
    numofrecords_se(i,2)=size(phedata2,1);
     numofrecords_se(i,3)=min(phedata2(:,3));
    numofrecords_se(i,4)=max(phedata2(:,3));
    
    num_station=unique(phedata2(:,1));
    
    numofrecords_se(i,5)=size(num_station,1);
    clear num_station
    clear phedata2
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%开始读取物候数据
for i=1:size(species_se,1)
    phedata2=dlmread([cd '\phedata\'  genus_se{i} ' ' species_se{i} ' ' num2str(pheID_se(i)) '_phe_se.dat']);        %所有的数据
    phedata2 = sortrows(phedata2,[1 2 3]);
     
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






   fprintf(['run'  genus_se{i,1} ' ' species_se{i,1} '\n']);
   for j=1:size(phedata2,1)
        if mod(j,100)==0
            fprintf(['run'  genus_se{i,1} ' ' species_se{i,1} ' '  num2str(j) '/' num2str(size(phedata2,1))  '\n']);
        end
   
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%寻找温度数据
        if j>=2 && phedata2(j,1)==phedata2(j-1,1);  %如果以前读取过，则无需再次读取，节约计算时间
             alllocation(j,1:3)=stationNUM(nn,2:4);
        else
             nn=find(stationNUM(:,1)==phedata2(j,1)  );

                 temseries=dlmread([cd  '\temdata\' num2str(stationNUM(nn,5))   '-'    num2str(stationNUM(nn,6))  '.txt']);
                 temseries1=[alldoy temseries];
                 alllocation(j,1:3)=stationNUM(nn,2:4);
        end
     nn1=find(phedata2(:,1)==phedata2(j,1));
     medianP=round(median(phedata2(nn1,4)));
     
    
       result1(j,1)=calculate_cumulativeCD(-60,medianP,phedata2(j,3),temseries1,[1 1]);                    %CA (小于5度日数)
       result1(j,2)=calculate_cumulativeCD(-60,medianP,phedata2(j,3),temseries1,[4 4]);                    %CA (小于7度日数)
       result1(j,3)=calculate_cumulativeGDD(1,phedata2(j,4),phedata2(j,3),temseries1,temseries,temseries,[2 2]); % 大于5度GDD,1开始
       result1(j,4)=calculate_cumulativeGDD(1,phedata2(j,4),phedata2(j,3),temseries1,temseries,temseries,[1 1]); % 大于0度GDD,1开始
       result1(j,5)=calculate_cumulativeGDD(32,phedata2(j,4),phedata2(j,3),temseries1,temseries,temseries,[2 2]); % 大于5度GDD,2开始 
       

       
        nline1=find(temseries1(:,1)==phedata2(j,3) & temseries1(:,2)==phedata2(j,4));
       % result1(j,5)=mean(temseries1(nline1-2:nline1+2,3));            %计算展叶当天的温度（前后5天的中值）
        result1(j,6)=calculate_meanT(-60,59,phedata2(j,3),temseries1); %计算冬季温度
        result1(j,7)=calculate_meanT(60,151,phedata2(j,3),temseries1); %计算春季温度                                                                                                            
        result1(j,8)=medianP; %计算物候期中值；
       
       clear nn1
   end
   
%    phedata2(isnan(result1(:,1)),:)=[];
%    alllocation(isnan(result1(:,1)),:)=[];
%    result1(isnan(result1(:,1)),:)=[];
   %alt1存了海拔信息
   
   xlswrite( [outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(pheID_se(i))   '.xlsx'],{'PEPID' 'BBCH','Year','DOY','lon','lat','alt','CA5','CA7','GDD5from1','GDD0from1','GDD5from2','Twinter','Tspring','medianP',},'sheet1','A1'); 
   xlswrite( [outputpath  genus_se{i,1}  ' ' species_se{i,1}  ' ' num2str(pheID_se(i))   '.xlsx'],[phedata2 alllocation result1],'sheet1','A2'); 
   dlmwrite( [outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(pheID_se(i))   '.txt'],[phedata2 alllocation result1]);

   clear result1
   clear phedata2
   clear phedata1
   clear alllocation
   clear nremove
   clear need2remove
   %%%%%%%%%%%%%%%%%%

    
end
