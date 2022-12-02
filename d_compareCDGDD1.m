function d_compareCDGDD1()
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

for i=18:size(species_se,1)
   fprintf( ['第' num2str(i) '个'  genus_se{i} ' ' species_se{i} '\n']);
   %如果有对应的物候期，就读取对应的观测数据;如果没有，就读取备用数据，并进行校正

   
       % phedata1=dlmread([cd '\phedata\'  genus_se{i} ' ' species_se{i}  '_phe.dat']);        %所有的物候数据
        
    %    num_se=phedata1
        
        
        
   
       phedata2=dlmread([outputpath '\'  genus_se{i} ' ' species_se{i} ' ' num2str(BBCHcode1(i,2)) '.txt']);        %读取观测的数据
 
       
        a=find(phedata2(:,12)==0);
        phedata2(a,:)=[];
        
%         phedata2(:,10)=phedata2(:,10)+BBCHcode1(i,3);
%         phedata2(:,11)=phedata2(:,11)+BBCHcode1(i,4);
%         phedata2(:,12)=phedata2(:,12)+BBCHcode1(i,5);

   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%选择最优的CA和GDD算法
    
   GDD_obs= phedata2(:,10:12);
   CA_obs=phedata2(:,8:9);
  for j=1:2
       for k=1:3
          t = CA_obs(:,j);
          y =GDD_obs(:,k);
           modelfun = @(x)(x(1)+x(2)*exp(-x(3)*t))-y;
               
            %%%%%%%%%%%%%%%%%%%%%获取观测数据的最小forcing
                     t1 = prctile(t,90);
                     nn=find(t>=t1);
                     upper_a=median(y(nn))*0.5;
                     %%%%%%%%%%%%%%%%%%%%%
                     
           lb = [upper_a,0,0];              %参数最小值
           ub = [inf,5000,0.2];       %参数最大值
           x0 = [40; max(y); 0.0036]; %初始参数
          options = optimoptions('lsqnonlin','Display','none');  
           warning('off')
           x = lsqnonlin(modelfun,x0,lb,ub,options);   %最小二乘参数求解
           
           yi=modelfun(x)+y;      %观测数据的模拟值
           r1=yi-y;               %每个观测值的误差
          
           RMSE(j,k)=sqrt(mean(r1.^2));
       end
  end
   
   [M,I] = min(RMSE(:));
   [optimalCA  optimalGDD]=find(RMSE==M);  
   if size(optimalCA,1)>1
       optimalCA=optimalCA(1,1);
       optimalGDD=optimalGDD(1,1);
   end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%拟合观测数据
                       t = CA_obs(:,optimalCA);
                       y =GDD_obs(:,optimalGDD);
                       modelfun = @(x)(x(1)+x(2)*exp(-x(3)*t))-y;
                     %  lb = [0,0,0];              %参数最小值
                     
                     %%%%%%%%%%%%%%%%%%%%%获取观测数据的最小forcing
                     t1 = prctile(t,90);
                     nn=find(t>=t1);
                     upper_a=prctile(y(nn),50)*0.5;
                    
                     %%%%%%%%%%%%%%%%%%%%%
                     
                       lb = [upper_a,0,0];              %参数最小值
                       ub = [inf,5000,0.2];       %参数最大值
                       x0 = [40; max(y); 0.0036];
                        warning('off')
                        x = lsqnonlin(modelfun,x0,lb,ub,options);   %求解最小二乘问题。

                      %观测数据
                     yi=modelfun(x)+y;      %观测数据的模拟值
                     r1=yi-y;               %每个观测值的误差
                     %检验
                      RMSE_obs=sqrt(mean(r1.^2));
                      Rd_obs=1-sum(r1.^2)/sum((y-mean(y)).^2);              
                %观测值的关系图 
                      h=scatter(t,y,'r');
                      hold on
                      num=1;
                      for x_show=min(t):max(t)
                          y_show(num,1)=x(1)+x(2)*exp(-x(3)*x_show);
                          num=num+1;
                      end
                      plot([min(t):max(t)],y_show,'r');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 拟合实验数据         
   row=find(strcmp(genus,genus_se(i))==1 & strcmp(species,species_se(i))==1 & prov_code==Prov_code_se(i) );
   %提取出实验数据
   GDD_exp=[GDD5Jan1(row) GDD0Jan1(row) GDD5Feb1(row)];
   CA_exp=[CA5(row) CA7(row) ];
   
   
   %%%%修正实验数据
         GDD_exp(:,1)=  GDD_exp(:,1)+BBCHcode1(i,3);
         GDD_exp(:,2)=  GDD_exp(:,2)+BBCHcode1(i,4);
         GDD_exp(:,3)=  GDD_exp(:,3)+BBCHcode1(i,5);
  
      %简单处理方法
            t_exp=CA_exp(:,optimalCA);
            y_exp=GDD_exp(:,optimalGDD);
 
            %实验数据的a，可以与观测数据一致；又可以不一致，取实验数据自己的。          
            if min(y_exp)>min(y)   %如果实验a的最小值大于观测a的最小值
                 x_exp(1)= upper_a;    
                    %拟合方法 正常拟合 
                   modelfun = @(x)(x(1)+x(2)*exp(-x(3)*t_exp))-y_exp;
                                       lb = [upper_a,0,0];              %参数最小值
                                       ub = [inf,5000,inf];           %参数最大值
                                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                       if i==1
                                            ub = [inf,400,inf]; 
                                       elseif i==21
                                            ub = [inf,800,inf];  
                                      elseif i==27
                                            ub = [inf,500,inf];  
                                       elseif i==28
                                            ub = [inf,400,inf];
                                        elseif i==29
                                            ub = [inf,1000,inf];
                                        elseif i==35
                                            ub = [inf,1200,inf];
                                       elseif i==36
                                            ub = [inf,1000,inf];
                                       elseif i==47
                                            ub = [inf,500,inf];
                                       elseif i==48
                                            ub = [inf,600,inf];
                                       elseif i==54
                                            ub = [inf,1400,inf];
                                             lb = [50,0,0]; 
                                       elseif i==55
                                            ub = [inf,1400,inf];
                                            lb = [100,0,0]; 
                                        elseif i==56
                                            ub = [inf,1400,inf];
                                            lb = [50,0,0]; 
                                       elseif i==59
                                                 ub = [inf,500,inf];
                                       elseif i==64
                                                 ub = [inf,1500,inf];
                                       end
                                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                       x0 = [40; max(y_exp); 0.0036]; 
                    warning('off')
                    x_exp = lsqnonlin(modelfun,x0,lb,ub);   %求解最小二乘问题。
                  x_exp=x_exp';                         
            else
                x_exp(1)= min(y_exp)*0.95;  %否则用实验a自己的最小值
                
                          coe = regress(log(y_exp-x_exp(1)),[CA_exp(:,optimalCA)  ones(size(CA_exp,1),1)]); %通过 log(y-a) =logb-cx去拟合
                          x_exp(3)=-coe(1);
                         x_exp(2)=exp(coe(2));
                       %如果不是下降的，下降速率改为0
                       if x_exp(3)<0
                           x_exp(3)=0;
                           x_exp(2)=mean(y_exp)-x_exp(1);
                       end
            end
            

           %根据拟合参数的预测结果
           num=1;
           for j=1:size(t_exp,1)
              yi_exp(num,1)=x_exp(1)+x_exp(2)*exp(-x_exp(3)*t_exp(j));
              num=num+1;
           end
          r1_exp=yi_exp-y_exp; 
    
       %%%%检验
     RMSE_exp=sqrt(mean(r1_exp.^2));
     Rd_exp=1-sum(r1_exp.^2)/sum((y_exp-mean(y_exp)).^2);
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%实验数据的画图对比
      hold on
     scatter(t_exp,y_exp,'filled','b');
     hold on
      num=1;
      for x_show=min(min(t),min(t_exp)):max(max(t),max(t_exp))
          y_show(num,1)=x_exp(1)+x_exp(2)*exp(-x_exp(3)*x_show);
          num=num+1;
      end
       plot([min(min(t),min(t_exp)):max(max(t),max(t_exp))],y_show,'b');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          

  %输出图片
    saveas(gca,[cd '\Compareresults\' genus_se{i} ' ' species_se{i} ' ' num2str(Prov_code_se(i)) '.jpg']);
   %输出原始数据
   xlswrite([cd '\Compareresults\'  'all_data.xlsx'],[t y],[genus_se{i} ' ' species_se{i} ' ' num2str(Prov_code_se(i))],'A2');
   xlswrite([cd '\Compareresults\'  'all_data.xlsx'],[t_exp y_exp],[genus_se{i} ' ' species_se{i} ' ' num2str(Prov_code_se(i))],'c2');
   xlswrite([cd '\Compareresults\'  'all_data.xlsx'],{'观测CA','观测FR','实验CA','实验FR'},[genus_se{i} ' ' species_se{i} ' ' num2str(Prov_code_se(i))],'A1');
   %%%%输出各种对比指标，参数等
   
   result(i,1)=prov_lat(row(1));  %实验纬度
   result(i,2)=prov_lon(row(1));  %实验经度
   result(i,3)=phylum(row(1));    %被子还是裸子
   result(i,4)=material(row(1));  %实验材料
   result(i,5)=chillingT(row(1)); %chilling处理方法
   result(i,6)=forcingT(row(1)); %forcing处理方法
   %与观测数据中心点的距离                
   C = unique(phedata2(:,5:7),'rows');
   latlon2=[median(C(:,2)) median(C(:,1))];
   latlon1=[prov_lat(row(1)) prov_lon(row(1))];
   [d1km d2km]=lldistkm(latlon1,latlon2);
   result(i,7)=d1km;    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%实验数据的拟合参数和检验结果
   result(i,8:12)=[x_exp RMSE_exp Rd_exp];
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%观测数据的参数
   result(i,13:17)=[x' RMSE_obs Rd_obs ];
 
   
   %实验数据的三个指标
  result(i,18)=x_exp(1); %minimum forcing 
  if x_exp(2)*x_exp(3)>1
    result(i,19)=log(1/x_exp(2)/x_exp(3))/(-x_exp(3)); %chilling requirement
  else
     result(i,19)=0;    
  end
  result(i,20)=-x_exp(2)*x_exp(3)*exp(-x_exp(3)*(min(t)+max(t))/2); %chilling sensitivity
   %观测数据的三个指标
  result(i,21)=x(1); % minimum forcing  
  if x(2)*x(3)>1
  result(i,22)=log(1/x(2)/x(3))/(-x(3)); % chilling requirement %当chilling sensitivity <1的时候代表chilling已经被满足；
    else
     result(i,22)=0;    
  end

  result(i,23)=-x(2)*x(3)*exp(-x(3)*(min(t)+max(t))/2); %chilling sensitivity     %观测到的chilling最大和最小之间时的敏感度
  
  num=1;
  for CA=min(t):max(t)
        fr_exp(num,1)=x_exp(1)+x_exp(2)*exp(-x_exp(3)*CA);
        fr_obs(num,1)=x(1)+x(2)*exp(-x(3)*CA);
        dif(num,1)= (fr_exp(num,1)- fr_obs(num,1))/fr_obs(num,1);
        num=num+1;
  end
  result(i,24)=    mean(abs(dif))      ;                                         %观测到的chilling最大和最小之间时的平均差异
  
  
  %最优的算法
  result(i,25)=optimalCA; %chilling requirement
  result(i,26)=optimalGDD; %chilling sensitivity
   
   xlswrite([cd '\Compareresults\'   'results.xlsx'],result(i,:),'sheet1',['E' num2str(i+1)]);
   xlswrite([cd '\Compareresults\'  'results.xlsx'],{'属','物种','物候期','发生','实验纬度','实验经度','被子/裸子','实验材料','chilling处理方法','forcing处理方法','与观测数据中心点距离','a_exp','b_exp','c_exp','RMSE_exp','R2_exp','a_obs','b_obs','c_obs',...
     'RMSE_obs','R2_obs','miniFR_exp','CR_exp','CS_exp','miniFR_obs','CR_obs','CS_obs','Similarity','ca_method','fr_method'},'sheet1','A1');
     
  
  xlswrite([cd '\Compareresults\'   'results.xlsx'],genus_se,'sheet1','A2');
  xlswrite([cd '\Compareresults\'   'results.xlsx'],species_se,'sheet1','B2');
 xlswrite([cd '\Compareresults\'   'results.xlsx'],pheID_se,'sheet1','C2'); 
 xlswrite([cd '\Compareresults\'   'results.xlsx'],Prov_code_se,'sheet1','D2');


   close
    
   clear row
   clear y_show
   clear yi_exp
   clear t
end

