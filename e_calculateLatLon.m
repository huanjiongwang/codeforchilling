function e_calculateLatLon()
addpath([cd '\function']);
%input
fileID = fopen('species_exp.txt');    %phenophase investigated (specie BBCHcode)
fileID1 = fopen('exp_data.txt');    %phenophase investigated (specie BBCHcode)
stationNUM=dlmread([cd '\temdata\station_EOSposition.txt']); %position of each station in the gridded tem data
outputpath=[cd '\CDGDDresults\'];
BBCHcode1=  dlmread('校正.txt');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[C1, ia, ic] = unique(stationNUM(:,1));
stationNUM=stationNUM(ia,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%读取所有待研究的specie-pro
C = textscan(fileID,'%s %s %f %f %f %f');
fclose(fileID);
genus_se=C{1};
species_se=C{2};
pheID_se=C{3};
Prov_code_se=C{4};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%读取实验数据
C1 = textscan(fileID1,'%s	%s	%s	%f	%f	%f	%f	%f	%f	%f	%f	%s	%f	%s	%s	%f	%f	%f	%f	%f	%f	%f	%f	%f	%f');
fclose(fileID1);
genus=C1{2};
species=C1{3};
BBCH=C1{4};
prov_code=C1{5};
prov_lat=C1{6};
prov_lon=C1{7};
CA5=C1{17};
CA7=C1{18};
GDD5Jan1=C1{19};
GDD0Jan1=C1{20};
GDD5Feb1=C1{21};
phylum	=C1{22};
material	=C1{23};
chillingT=C1{24};
forcingT=C1{25};

obs_pos_all=[];
exp_pos_all=[];
for i=1:size(species_se,1)
   fprintf( ['第' num2str(i) '个'  genus_se{i} ' ' species_se{i} '\n']);
   %如果有对应的物候期，就读取对应的观测数据;如果没有，就读取备用数据，并进行校正

   
       % phedata1=dlmread([cd '\phedata\'  genus_se{i} ' ' species_se{i}  '_phe.dat']);        %所有的物候数据
        
    %    num_se=phedata1
        
        
        
   
       phedata2=dlmread([outputpath '\'  genus_se{i} ' ' species_se{i} ' ' num2str(BBCHcode1(i,2)) '.txt']);        %读取观测的数据
        a=find(phedata2(:,12)==0);
        phedata2(a,:)=[];
        
        %观测的位置
        obs_pos=unique([phedata2(:,6) phedata2(:,5)],'rows');
        num_obs(i,1)=size(phedata2,1);
        
        obs_pos_all=cat(1,obs_pos_all,obs_pos);
        obs_pos_all=unique(obs_pos_all,'rows');
        
        
    row=find(strcmp(genus,genus_se(i))==1 & strcmp(species,species_se(i))==1 & prov_code==Prov_code_se(i) );
   %提取出实验数据
   GDD_exp=[GDD5Jan1(row) GDD0Jan1(row) GDD5Feb1(row)];
   CA_exp=[CA5(row) CA7(row) ];
   
    num_exp(i,1)=size(CA_exp,1);
    
   exp_pos=[prov_lat(row) prov_lon(row) ];
   exp_pos=unique(exp_pos,'rows');
        
   exp_pos_all=cat(1,exp_pos_all,exp_pos);
   exp_pos_all=unique(exp_pos_all,'rows');

    
    
        clear obs_pos
        clear exp_pos
       
end
   
    xlswrite([cd '\Compareresults\'   'all_station.xlsx'],obs_pos_all,'sheet1','A2');
    xlswrite([cd '\Compareresults\'  'all_station.xlsx'],{'观测纬度','观测经度'},'sheet1','A1');
    
    xlswrite([cd '\Compareresults\'   'all_station.xlsx'],exp_pos_all,'sheet2','A2');
    xlswrite([cd '\Compareresults\'  'all_station.xlsx'],{'实验纬度','实验经度'},'sheet2','A1');   
    
     
   xlswrite([cd '\Compareresults\'  'all_station.xlsx'],{'观测数量','实验数量'},'sheet3','A1'); 
  xlswrite([cd '\Compareresults\'   'all_station.xlsx'],[num_obs num_exp],'sheet3','A2');
