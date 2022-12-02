function c_b_calculateCDGDD1()
%���ÿ��������Ҫ����ڵ�GDD��CD


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath([cd '\function\'])

%input
fileID = fopen('species_exp1.txt');    %phenophase investigated (specie BBCHcode)
stationNUM=dlmread([cd '\temdata\station_EOSposition.txt']); %position of each station in the gridded tem data
outputpath=[cd '\CDGDDresults\'];
alldoy=dlmread([cd '\temdata\alldoy.txt']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[C1, ia, ic] = unique(stationNUM(:,1));
stationNUM=stationNUM(ia,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ȡ�����
C = textscan(fileID,'%s %s %f %f %f %f');
fclose(fileID);
genus_se=C{1};
species_se=C{2};
BBCH1=C{4};
%BBCH2=C{4};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ʼ��ȡ�������
% for i=1:size(species_se,1)
%     i
%     phedata2=dlmread([cd '\phedata\'  genus_se{i} ' ' species_se{i}  '_phe.dat']);        %���е�����
%     phedata2 = sortrows(phedata2,[1 2 3]);
%     nrow=find(phedata2(:,2)==BBCHcode1(i,2));
%     
%     if size(nrow,1)>0
%         phedata2=phedata2(nrow,:);
%         numofrecords_se(i,1)=BBCHcode1(i,2);
%         numofrecords_se(i,2)=size(phedata2,1);
%          numofrecords_se(i,3)=min(phedata2(:,3));
%         numofrecords_se(i,4)=max(phedata2(:,3));
%         num_station=unique(phedata2(:,1));
%         numofrecords_se(i,5)=size(num_station,1);
%     else
%          phedata2=phedata2(nrow,:);
%         numofrecords_se(i,1)=BBCHcode1(i,2);
%         numofrecords_se(i,2)=size(phedata2,1);
%          numofrecords_se(i,3)=nan;
%         numofrecords_se(i,4)=nan;
%         numofrecords_se(i,5)=nan;
%     end
%     clear num_station
%     clear phedata2
%     clear nrow
%     
% end
% 
% genus_se=C{1};
% species_se=C{2};
% BBCH=C{3};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ʼ��ȡ�������
for i=1:size(species_se,1)
    phedata2=dlmread([cd '\phedata\'  genus_se{i} ' ' species_se{i}  '_phe.dat']);        %���е�����
    phedata2 = sortrows(phedata2,[1 2 3]);
         nrow=find(phedata2(:,2)==BBCH1(i,1));
    if size(nrow,1)>10 % exist([outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(BBCH1(i,1))   '.xlsx'])==0
          phedata2=phedata2(nrow,:);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ȥ��outliers
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ȥ��С��30�ʹ���180�ġ���Σ���ȥ��2.5����׼����������֡�
            nrow1=find(phedata2(:,4)<180 & phedata2(:,4)>30);
            phedata2=phedata2(nrow1,:);

            
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�������ȥ�����
             allstation_se=unique(phedata2(:,1));  %����վ��
             allphedata=[];
               for j=1:size(allstation_se,1);
                    nn=find(phedata2(:,1)==allstation_se(j,1));
                    Inditimeseries=phedata2(nn,1:4);
                    std_ts=std(Inditimeseries(:,4));
                    
                     if std_ts<25 & size(nn,1)>10;          
                       y = mad(Inditimeseries(:,4),1);
                       range=[median(Inditimeseries(:,4))-3*y  median(Inditimeseries(:,4))+3*y ];
                        allrwo_remove=find(Inditimeseries(:,4)>range(2) | Inditimeseries(:,4)<range(1));
                       if size(allrwo_remove,1)>0
                           Inditimeseries(allrwo_remove,:)=[];
                       end

                        allphedata=cat(1,allphedata,Inditimeseries); 
                        
                     elseif std_ts<25 & size(nn,1)<10;   %ֱ�Ӽ���   
                         
                            allphedata=cat(1,allphedata,Inditimeseries); 
                         
                     elseif  std_ts>=25 %ֱ��ɾ��
                       
                     end

                    clear nn
                    clear allrwo_remove
               end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%һ���ж������Ļ�ȡ��ֵ
                
                
         phedata2=allphedata;
         deleuse=phedata2(:,1:3);
        [C,ia,ic] = unique(deleuse,'rows');
        if size(C,1)~=size(deleuse,1)
            for j=1:size(C,1)
                    nn=find(phedata2(:,1)==C(j,1) & phedata2(:,2)==C(j,2) & phedata2(:,3)==C(j,3));
                   phedata3(j,1:3)=C(j,1:3);
                   phedata3(j,4)=round(median(phedata2(nn,4)));
            end
           phedata2=phedata3;
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



           fprintf(['run'  genus_se{i,1} ' ' species_se{i,1} '\n']);
           for j=1:size(phedata2,1)
                if mod(j,100)==0
                    fprintf(['run'  genus_se{i,1} ' ' species_se{i,1} ' '  num2str(j) '/' num2str(size(phedata2,1))  '\n']);
                end



                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Ѱ���¶�����
                if j>=2 && phedata2(j,1)==phedata2(j-1,1);  %�����ǰ��ȡ�����������ٴζ�ȡ����Լ����ʱ��
                     alllocation(j,1:3)=stationNUM(nn,2:4);
                else
                     nn=find(stationNUM(:,1)==phedata2(j,1)  );
                        if isnan(stationNUM(nn,5))==0 
                         temseries=dlmread([cd  '\temdata\' num2str(stationNUM(nn,5))   '-'    num2str(stationNUM(nn,6))  '.txt']);
                           if  size(temseries,1)==size(alldoy,1)
                               temseries1=[alldoy temseries];
                               alllocation(j,1:3)=stationNUM(nn,2:4);
                               temseriesNaN=0;
                           else
                                temseriesNaN=1;
                           end
                        else
                              alllocation(j,1:3)=stationNUM(nn,2:4);
                              temseriesNaN=1;
                        end
                end
          %   nn1=find(phedata2(:,1)==phedata2(j,1));
           %  medianP=round(median(phedata2(nn1,4)));

            if temseriesNaN==0
               result1(j,1)=calculate_cumulativeCD(-60,phedata2(j,4),phedata2(j,3),temseries1,[1 1]);                    %CA (С��5������)
               result1(j,2)=calculate_cumulativeCD(-60,phedata2(j,4),phedata2(j,3),temseries1,[4 4]);                    %CA (С��7������)
               result1(j,3)=calculate_cumulativeGDD(1,phedata2(j,4),phedata2(j,3),temseries1,temseries,temseries,[2 2]); % ����5��GDD,1��ʼ
               result1(j,4)=calculate_cumulativeGDD(1,phedata2(j,4),phedata2(j,3),temseries1,temseries,temseries,[1 1]); % ����0��GDD,1��ʼ
               result1(j,5)=calculate_cumulativeGDD(32,phedata2(j,4),phedata2(j,3),temseries1,temseries,temseries,[2 2]); % ����5��GDD,2��ʼ 



                nline1=find(temseries1(:,1)==phedata2(j,3) & temseries1(:,2)==phedata2(j,4));
                result1(j,6)=calculate_meanT(-60,59,phedata2(j,3),temseries1); %���㶬���¶�
                result1(j,7)=calculate_meanT(60,151,phedata2(j,3),temseries1); %���㴺���¶�                                                                                                            
            else
                result1(j,1:7)=NaN;
            end
               clear nn1
           end


           nrow2=find(isnan( result1(:,6))==1);
           result1(nrow2,:)=[];
           phedata2(nrow2,:)=[];
            alllocation(nrow2,:)=[];

           xlswrite( [outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(BBCH1(i,1))   '.xlsx'],{'PEPID' 'BBCH','Year','DOY','lon','lat','alt','CA5','CA7','GDD5from1','GDD0from1','GDD5from2','Twinter','Tspring',},'sheet1','A1'); 
           xlswrite( [outputpath  genus_se{i,1}  ' ' species_se{i,1}  ' ' num2str(BBCH1(i,1))   '.xlsx'],[phedata2 alllocation result1],'sheet1','A2'); 
           dlmwrite( [outputpath  genus_se{i,1} ' ' species_se{i,1} ' ' num2str(BBCH1(i,1))   '.txt'],[phedata2 alllocation result1]);

           clear result1
           clear phedata2
              clear phedata3
           clear phedata1
           clear alllocation
           clear nremove
           clear need2remove
   %%%%%%%%%%%%%%%%%%
    else
        
        
    end
    
end
