function b_a_selectdata()




%选出需要计算的物候期


%input
phedata=[cd '\phedata\']; %phe data path
fileID = fopen('species.txt');    %phenophase investigated (specie BBCHcode)
outputpath=[cd '\phedata\'];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%读取物候期
C = textscan(fileID,'%s %s %f');
fclose(fileID);
genus=C(1);
species=C(2);
allthesatation=[];
allsts(:,1)=[0:size(species{1},1)]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%开始读取物候数据
for i=1:size(species{1},1)
    if i==26
       1 
    end
    phedata1=dlmread([phedata '\'   genus{1}{i} ' ' species{1}{i}  '_phe.dat']);        %所有的数据
    phestation=dlmread([phedata '\'   genus{1}{i} ' ' species{1}{i}  '_station.dat']);   
    phests=dlmread([phedata '\'   genus{1}{i} ' ' species{1}{i}  '_sts.dat']);   
      
    if phests(1,1)==0;
        phests(1,:)=[];
    end
    for j=1:size(phests,1)
          [row,col] = find(allsts(1,:)==phests(j,1));
          if size(row,2)==0
             allsts(1,size(allsts,2)+1)=phests(j,1);
             allsts(i+1,size(allsts,2))=phests(j,2);
          else
              allsts(i+1,col)=phests(j,2);  
          end
         
    end
        
    allthesatation=cat(1,allthesatation,phestation);
    allthesatation=unique(allthesatation,'rows');
   

end
B = sortrows(allsts');
allsts=B';





  allstation_spe=allthesatation;
  %删掉站点编号一致但是经纬度稍有区别的站点记录。
  num=1;
   allstation_spe =unique(allstation_spe,'rows');
   
  allcode=unique(allstation_spe(:,1));
  for i=1:size(allcode,1)
     nn=find(allstation_spe(:,1)==allcode(i));
     if size(nn,1)>1
         repet(num,1)=nn(2,1);
         num=num+1;
     end
     clear nn
  end
    if num>1
            allstation_spe(repet,:)=[];
    end

dlmwrite('allstation_se.txt',  allstation_spe);   
dlmwrite('allsts.txt',  allsts);   

xlswrite('allsts_EU.xlsx',[genus{1} species{1}],'sheet1','A2')
xlswrite('allsts_EU.xlsx',allsts,'sheet1','C1')




