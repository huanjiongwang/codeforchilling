function e_calculateLatLon()
addpath([cd '\function']);
%input
fileID = fopen('species_exp.txt');    %phenophase investigated (specie BBCHcode)
fileID1 = fopen('exp_data.txt');    %phenophase investigated (specie BBCHcode)
stationNUM=dlmread([cd '\temdata\station_EOSposition.txt']); %position of each station in the gridded tem data
outputpath=[cd '\CDGDDresults\'];
BBCHcode1=  dlmread('У��.txt');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[C1, ia, ic] = unique(stationNUM(:,1));
stationNUM=stationNUM(ia,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ȡ���д��о���specie-pro
C = textscan(fileID,'%s %s %f %f %f %f');
fclose(fileID);
genus_se=C{1};
species_se=C{2};
pheID_se=C{3};
Prov_code_se=C{4};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ȡʵ������
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
   fprintf( ['��' num2str(i) '��'  genus_se{i} ' ' species_se{i} '\n']);
   %����ж�Ӧ������ڣ��Ͷ�ȡ��Ӧ�Ĺ۲�����;���û�У��Ͷ�ȡ�������ݣ�������У��

   
       % phedata1=dlmread([cd '\phedata\'  genus_se{i} ' ' species_se{i}  '_phe.dat']);        %���е��������
        
    %    num_se=phedata1
        
        
        
   
       phedata2=dlmread([outputpath '\'  genus_se{i} ' ' species_se{i} ' ' num2str(BBCHcode1(i,2)) '.txt']);        %��ȡ�۲������
        a=find(phedata2(:,12)==0);
        phedata2(a,:)=[];
        
        %�۲��λ��
        obs_pos=unique([phedata2(:,6) phedata2(:,5)],'rows');
        num_obs(i,1)=size(phedata2,1);
        
        obs_pos_all=cat(1,obs_pos_all,obs_pos);
        obs_pos_all=unique(obs_pos_all,'rows');
        
        
    row=find(strcmp(genus,genus_se(i))==1 & strcmp(species,species_se(i))==1 & prov_code==Prov_code_se(i) );
   %��ȡ��ʵ������
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
    xlswrite([cd '\Compareresults\'  'all_station.xlsx'],{'�۲�γ��','�۲⾭��'},'sheet1','A1');
    
    xlswrite([cd '\Compareresults\'   'all_station.xlsx'],exp_pos_all,'sheet2','A2');
    xlswrite([cd '\Compareresults\'  'all_station.xlsx'],{'ʵ��γ��','ʵ�龭��'},'sheet2','A1');   
    
     
   xlswrite([cd '\Compareresults\'  'all_station.xlsx'],{'�۲�����','ʵ������'},'sheet3','A1'); 
  xlswrite([cd '\Compareresults\'   'all_station.xlsx'],[num_obs num_exp],'sheet3','A2');
