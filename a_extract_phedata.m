function a_extract_phedata()
%��ԭʼ��������ȡ������������ݣ��洢��phedata

%compile PEP 725 data 

%users settings%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%users settings
obfilepath=[cd '\species.txt'];                    %the file was all phenophase e.g. first row Abies alba	11 second row Acer pseudoplatanus	11
PEPpath=[cd '\original data\PEP725data\'];            %the original pPEP725 data

%output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputfilepath=[cd '\phedata\']; 
%three file   (1)_phe.dat   (2)_sts.dat(pheID numofrecord star end numofstation)   (2)_station.dat
%allstation.txt    all the stations
%alltherecord.txt     num of record for each phenophase




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fileID = fopen(obfilepath);    %phenophase������Ҫ�о��������
C = textscan(fileID,'%s %s %f');
fclose(fileID);
genus=C(1);
species=C(2);




for i=1:size(species{1},1)
     i
     %phedata1=dlmread([phedata '\'  genus{1}{i} ' ' species{1}{i}  '_phe.dat']);  
     %%��ȡĿ¼�������ļ�
     if 1%exist([outputfilepath genus{1}{i} ' ' species{1}{i} '_phe.dat'],'file')==0 || exist([outputfilepath genus{1}{i} ' ' species{1}{i} '_sts.dat'],'file')==0 
         i
        filepath =[ PEPpath genus{1}{i} ' ' species{1}{i}];
        dirOutput1 = dir(fullfile(filepath,'*stations.csv'));
        plyName1 = {dirOutput1.name};
        
        dirOutput2 = dir(fullfile(filepath,['*' genus{1}{i} '*'  '.csv']));
        plyName2 = {dirOutput2.name};
        
         %%%%%%%%%�ۺ�վ������
        allstation=[];
        for country=1:size(plyName1,2) 
   
            fprintf(['run ' genus{1}{i} ' ' species{1}{i}  ' ' plyName1{country}  '\n']);  
           fileID = fopen([PEPpath   genus{1}{i} ' ' species{1}{i} '\'    plyName1{country}]);
            C = textscan(fileID,'%s %s %s %s %s %s %s %s','Delimiter',';','EmptyValue',-Inf);
            fclose(fileID);
               
                
             couuntrystation= [ cellfun(@str2num,C{1}(2:end))  cellfun(@str2num,C{3}(2:end)) cellfun(@str2num,C{4}(2:end))  cellfun(@str2num,C{5}(2:end))];

            allstation=cat(1,allstation,couuntrystation);
            clear couuntrystation
            clear couuntryalldata
       end


        
        %�ۺ��������
        alldata=[];
       for country=1:size(plyName2,2) 
           fprintf(['run ' genus{1}{i} ' ' species{1}{i}  ' ' plyName2{country}  '\n']);  
           
           fileID = fopen([PEPpath   genus{1}{i} ' ' species{1}{i} '\'    plyName2{country}]);
            C = textscan(fileID,'%s %s %s %s ','Delimiter',';','EmptyValue',-Inf);
            fclose(fileID);
         
          couuntryalldata= [ cellfun(@str2num,C{1}(2:end))  cellfun(@str2num,C{2}(2:end)) cellfun(@str2num,C{3}(2:end)) cellfun(@str2num,C{4}(2:end))  ];
            
            alldata=cat(1,alldata,couuntryalldata);
            clear couuntryalldata
       end
       
       %�����Ϣ��alldata��ԭʼ���ݣ�sts��ͳ����Ϣ;allstation��վ����Ϣ
       pheph=unique(alldata(:,2));
       for j=1:size(pheph,1)
          sts(j,1)=pheph(j);
          numr=find(alldata(:,2)==pheph(j));
          sts(j,2)=size(numr,1); %num of record;
          sts(j,3)=min(alldata(numr,3)); %start year
          sts(j,4)=max(alldata(numr,3));  %end year
          sts(j,5)=size(unique(alldata(numr,1)),1);  %num of station
       end
       clear C
       
      
      
      dlmwrite([outputfilepath genus{1}{i} ' ' species{1}{i} '_phe.dat'],  alldata);
      dlmwrite([outputfilepath genus{1}{i} ' ' species{1}{i} '_sts.dat'],  sts);  
      dlmwrite([outputfilepath genus{1}{i} ' ' species{1}{i} '_station.dat'],  allstation);   
      
       clear sts
       clear pheph
       clear alldata
       clear allstation
       

       
     end   
end


      
      