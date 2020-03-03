%% Voltage value segregation by phase
% Run file immediately after executing "PCA_data_extract_diff_test_systems.m"
warning('off','all');
save_fig=0;
excel_write=0;
trans_tap=0;
test_system='IEEE_13_test';
prim_end_index=0;

% 0 def all node values 1 all succeding secondary nodes from index 2 Primary nodes from start 
secondary=0;
if(secondary==1)
    V=Bus.Vpu(:,prim_end_index:end);
    bus_names=Bus.Node_names(prim_end_index:end,1);
elseif(secondary==2)
    V=Bus.Vpu(:,1:prim_end_index-1);
    bus_names=Bus.Node_names(1:prim_end_index-1,1);
else
    V=Bus.Vpu;
    bus_names=Bus.Node_names;
end
% Splitting names to obtain bus names
sec_split=0;
for i=1:size(bus_names,1)
    split_string=strsplit(bus_names{i,1},{'_','.'});
    PhaseNum(1,i)=str2num(split_string{1,end});
    sec(1,i)=split_string(1,1);
end
V1full=[bus_names(PhaseNum==1,1)'; num2cell(V(:,PhaseNum==1))];
% for 123 bus system
idx=find(strcmp(V1full(1,:),V1full{1,size(V1full,2)}));
V1full(:,idx)=[];
V2full=[bus_names(PhaseNum==2,1)'; num2cell(V(:,PhaseNum==2))];
V3full=[bus_names(PhaseNum==3,1)'; num2cell(V(:,PhaseNum==3))];
%% Finding beginning of secondary nodes marked by x
% IMP: modify this code for new test system
if(sec_split)
    % Multi-step loses index
    sec_1=sec(:,PhaseNum==1);
    sec_2=sec(:,PhaseNum==2);
    sec_3=sec(:,PhaseNum==3);
    % Finds non-number buses and x but loses on position
    sec_string=cellfun(@(x)(isempty(str2num(x))),sec_1,'UniformOutput',false); 
    index=cell2mat(sec_string);
    sec_possib=(sec_1(index));
    sec_cell=cellfun(@(x)(strcmp(x,'x')),sec_possib,'UniformOutput',false);
    sec_start_phase1=find(cell2mat(cellfun(@(x)(strcmp(x,'x')),sec_1,'UniformOutput',false)),1);
    sec_start_phase2=find(cell2mat(cellfun(@(x)(strcmp(x,'x')),sec_2,'UniformOutput',false)),1);
    sec_start_phase3=find(cell2mat(cellfun(@(x)(strcmp(x,'x')),sec_3,'UniformOutput',false)),1);
    V1=V1full(:,1:sec_start_phase1-1);
    V2=V2full(:,1:sec_start_phase2-1);
    V3=V3full(:,1:sec_start_phase3-1);
else
    V1=V1full;
    V2=V2full;
    V3=V3full;
end
%% Writing outputs to Excel file
% Determines wrting output into excel files
file_path='C:/PCAdatasets/';
parameter='volt';
file_extension='.xlsx';
 if(excel_write==1)
        xlswrite(strcat(file_path,test_system,parameter,file_extension),V1,1);
        xlswrite(strcat(file_path,test_system,parameter,file_extension),V2,2);
        xlswrite(strcat(file_path,test_system,parameter,file_extension),V3,3);
        if(trans_tap)
            parameter='Transftap';
            xlswrite(strcat(file_path,test_system,parameter,file_extension),Transformertap,1);
        end
 end
%% Voltage plot of 1,2 or 3 phase bus
% Determine indices of Bus phases and file path
busnum='650';
fig_name=strcat(busnum,parameter);
file_extension='.png';
file_path='C:\Users\WSU-PNNL\OneDrive - Washington State University (email.wsu.edu)\Programs\MATLAB programs\PCA research project\PCA plots and results\Applying PCA\Event validation 123 Dec 30\use_case_capa\';
time_step=size(V1,1);
busphaseA=strcat(busnum,'.1');
busphaseB=strcat(busnum,'.2');
busphaseC=strcat(busnum,'.3');
busnamesphaseA=cellfun(@(x)x(1,:),V1(1,:),'UniformOutput',false);
busnamesphaseB=cellfun(@(x)x(1,:),V2(1,:),'UniformOutput',false);
busnamesphaseC=cellfun(@(x)x(1,:),V3(1,:),'UniformOutput',false);
Aphaseindex=find(strcmp(busphaseA,busnamesphaseA));
Bphaseindex=find(strcmp(busphaseB,busnamesphaseB));
Cphaseindex=find(strcmp(busphaseC,busnamesphaseC));
clear str_arr;
f1=figure;
% A phase
if(~isempty(Aphaseindex))
    plot(cell2mat(V1(2:time_step,Aphaseindex)),'Color',[152 30 50]./255); %Bus 1005
    str_arr{1}=strcat(busnum,'Phase A');
end
hold on;
% B phase
if(~isempty(Bphaseindex))
    plot(cell2mat(V2(2:time_step,Bphaseindex)),'Color',[94 106 113]./255); %Bus 1006
    str_arr{2}=strcat(busnum,'Phase B');
end
hold on;
% C phase
if(~isempty(Cphaseindex))
    plot(cell2mat(V3(2:time_step,Cphaseindex)),'Color',[182 114 51]./255); %Bus 1005
    xlabel('Timesteps');
    ylabel('Voltage at a bus');
    str_arr{3}=strcat(busnum,'Phase C');
end
if(~isempty(Aphaseindex)||~isempty(Bphaseindex)||~isempty(Cphaseindex))
    index=find(~cellfun(@isempty,str_arr(1,:)));
    legend(str_arr(index));
    if(save_fig)
         saveas(f1,strcat(file_path,test_system,fig_name,file_extension));
    end
end
%% Observation matrix plot
% Visualizing initial nodes for large test systems
select_nodes=0;
node_number=242;
if(select_nodes)
    voltage_prim_data=cell2mat(V1(2:25,2:node_number));
else
    voltage_prim_data=cell2mat(V1(2:end,:));
    node_number='All';
end

% Column plot of matrix
fig_name='column_volt2';
fig2=figure;
x=linspace(1,size(voltage_prim_data,1),size(voltage_prim_data,1));
plot(x,voltage_prim_data,'-*');
xlabel('No of time steps (Line- One specific node of feeder )');
ylabel('Voltages(pu)');
if(save_fig)
    saveas(fig2,strcat(file_path,test_system,fig_name,'Node_number',num2str(node_number),file_extension));
end

% Row plot of matrix
fig_name='row_volt1';
fig3=figure;
x1=linspace(1,size(voltage_prim_data,2),size(voltage_prim_data,2));
plot(x1,voltage_prim_data,'-*');
xlabel('Different Nodes of phase 1 of feeder(Line - One specific timestep)');
ylabel('Voltages(pu)');
if(save_fig)
    saveas(fig3,strcat(file_path,test_system,fig_name,'Node_number',num2str(node_number),file_extension));
end 

% One PCElement Load value to check for load profile randomness
fig1=figure;
load_index=2;
fig_name=strcat('Power',PCElement(load_index).name);
plot(PCElement(1).Pmatrix(:,load_index),'-');
xlabel('Time step');
ylabel('Load(kW)');
if(save_fig)
    saveas(fig1,strcat(file_path,test_system,fig_name,file_extension));
end
