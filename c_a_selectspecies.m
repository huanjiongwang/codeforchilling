function c_a_selectspecies()

%ѡ����Ҫ����������
%����ʵ�����֣�ѡ����Ӧ������ڣ��������������Լ����õ�����ڣ�����������

%%%%%

%input
fileID = fopen('species.txt');    %phenophase investigated (specie BBCHcode)
fileID2 = fopen('species_exp.txt'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ȡ�����
C = textscan(fileID,'%s %s %f');
fclose(fileID);
genus=C{1};
species=C{2};



%%%%%%%%%%%%%%%%%%%%ʵ�������
C2 = textscan(fileID2,'%s %s %f %f');
fclose(fileID2);
genus_exp=C2{1};
species_exp=C2{2};
BBCHcode=C2{3};
BBCHcode1=BBCHcode;
dataP=dlmread('allsts.txt');

for i=1:size(species_exp,1);
     % phedata1=dlmread([phedata '\'   genus{i} ' ' species{i}  '_phe.dat']);   
    a=find(strcmp(genus,genus_exp{i})==1 & strcmp(species,species_exp{i})==1);
    %[genus(a)  species(a) ]
    if size(a,1)>0
       phedata=[dataP(1,:) ; dataP(a+1,:)]';
           line1=find(phedata(:,1)==7);
           line2=find(phedata(:,1)==9);

          [M,I] =  max(phedata([line1 ;line2 ],2));
        if I==1
            phe_se(1,1)=7;
        elseif I==2
            phe_se(1,1)=9;
        end
        phe_se(1,2)=M;
          
           line1=find(phedata(:,1)==10);
           line2=find(phedata(:,1)==11);
          [M,I] =  max(phedata([line1 ;line2 ],2));
        if I==1
            phe_se(1,3)=10;
        elseif I==2
            phe_se(1,3)=11;
        end
        phe_se(1,4)=M;
          
       
        
        
       if BBCHcode(i)==9 |  BBCHcode(i)==7
          BBCHcode1(i,2:3)=phe_se(1,1:2);
          BBCHcode1(i,4:5)=phe_se(1,3:4);
           
       elseif BBCHcode(i)==11
          BBCHcode1(i,2:3)=phe_se(1,3:4);
          BBCHcode1(i,4:5)=phe_se(1,1:2); 
           
       end
       
    else
        phedata=0;
    end
    

    
    
    
    dlmwrite('BBCHcode1.txt',BBCHcode1)  %�����Ҫ����GDD��CD��
        
end

1
