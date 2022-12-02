function c_c_compareBBCH()
%对比主要物候期与次要物候期的CD和GDD需求差异，输出结果拷贝到实验数据的excel中，作为部分物种需要调整的依据。

%input
fileID = fopen('species_exp1.txt');    %phenophase investigated (specie BBCHcode)
outputpath=[cd '\CDGDDresults\'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%读取所有待研究的物候期
C = textscan(fileID,'%s %s %f %f %f %f');
fclose(fileID);
genus_se=C{1};
species_se=C{2};
BBCH1=C{3};
BBCH2=C{4};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%读取实验数据



for i=1:size(species_se,1)
       [ genus_se{i} ' ' species_se{i}]
       
  if exist([outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(BBCH1(i,1))   '.xlsx'])~=0 & exist([outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(BBCH2(i,1))   '.xlsx'])~=0
    
       phedata1=dlmread([outputpath '\'  genus_se{i} ' ' species_se{i} ' ' num2str(BBCH1(i,1)) '.txt']);        %读取观测的数据
       a=find(phedata1(:,12)==0);
       phedata1(a,:)=[];
     
      phedata2=dlmread([outputpath '\'  genus_se{i} ' ' species_se{i} ' ' num2str(BBCH2(i,1)) '.txt']);        %读取观测的数据
       a=find(phedata2(:,12)==0);
       phedata2(a,:)=[];
       
       for j=1:size(phedata1,1)
           nn=find(phedata2(:,1)==phedata1(j,1) & phedata2(:,3)==phedata1(j,3));
           if size(nn,1)>0
                results(j,1:4)=phedata1(j,1:4);
                results(j,5:7)=phedata1(j,10:12);
                results(j,8)=phedata2(nn,4);
                results(j,9:11)=phedata2(nn,10:12);
           else
                results(j,1:4)=phedata1(j,1:4);
                results(j,5:7)=phedata1(j,10:12);  
                 results(j,8)=nan;
                results(j,9:11)=[nan nan nan];   
           end
           
       end
       
       
       
           
   
         nn1=find(isnan(results(:,9))==1   | (results(:,8)-results(:,4))<=0 );
         results(nn1,:)=[];  
      
       
           inter(i,1)=size(phedata1,1);
           inter(i,2)=size(phedata2,1);
           inter(i,3)=size(results,1);
           inter(i,4)=median(results(:,9)-results(:,5),'omitnan');
           inter(i,5)=median(results(:,10)-results(:,6),'omitnan');
           inter(i,6)=median(results(:,11)-results(:,7),'omitnan');
          
   
  elseif exist([outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(BBCH1(i,1))   '.xlsx'])~=0
      
      inter(i,1:6)=nan;
        phedata1=dlmread([outputpath '\'  genus_se{i} ' ' species_se{i} ' ' num2str(BBCH1(i,1)) '.txt']);        %读取观测的数据
       a=find(phedata1(:,12)==0);
       phedata1(a,:)=[];
      inter(i,1)=size(phedata1,1);
      
  elseif  exist([outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(BBCH2(i,1))   '.xlsx'])~=0
      
      inter(i,1:6)=nan;
       phedata2=dlmread([outputpath '\'  genus_se{i} ' ' species_se{i} ' ' num2str(BBCH2(i,1)) '.txt']);        %读取观测的数据
       a=find(phedata2(:,12)==0);
       phedata2(a,:)=[];
      inter(i,2)=size(phedata2,1);
  else
       inter(i,1:6)=nan;
   
  end

  
  
   
   clear results
   
end
1

