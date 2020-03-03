%% Setup openDSS interface
%Initialize Opendss
DSSObj=actxserver('OpenDSSEngine.DSS'); % Instantiate the opendss
DSSStart=DSSObj.Start(0); % start opendss by zero

% Start the solver
if DSSStart
    fprintf('\n Connection is Established \n');
else
    fprintf('Unable to start Opendss engine');
end

% Setup text, circuit and solution interfaces
DSSText=DSSObj.Text;
DSSCircuit=DSSObj.ActiveCircuit;
DSSSolution=DSSCircuit.Solution;
DSSCtrlQueue=DSSCircuit.CtrlQueue;
DSSText.command='Clear';
%% Compiling IEEE 123, 342, 8500 node models EPRI 7, 24 node system
DSSText.Command='Compile  "C:\OpenDSS\IEEETestCases\13Bus\IEEE13Nodeckt.dss"';
% DSSText.Command='Compile  "C:\OpenDSS\IEEETestCases\123Bus\IEEE123Master.dss"';
% DSSText.Command='Compile "C:\Program Files\OpenDSS\IEEETestCases\NREL\make_123pv_cim.dss"';
% DSSText.command='Compile  "D:\OpenDSS\OpenDSS\IEEETestCases\LVTestCaseNorthAmerican\Master.DSS"';
% DSSText.command='Compile  "C:\OpenDSS\IEEETestCases\8500-Node\Master-unbal.dss"';
% DSSText.command='Compile  "D:\OpenDSS\OpenDSS\EPRITestCircuits\ckt7\Master_ckt7.dss"';
%% Assign loadshape and run the system
DSSText.Command='Set Mode=daily stepsize=1h number=1';
DSSText.Command='Redirect "C:\OpenDSS\Examples\Loadshapes\loadshape_daily.DSS"';
DSSText.command='Batchedit load..* daily=LoadShape1';
%% Compiling 342 node system
% DSSText.command='Set mode=yearly stepsize=15m number=1';
% DSSText.command='Redirect D:\OpenDSS\OpenDSS\IEEETestCases\LVTestCaseNorthAmerican\AssignLoadshapeYearly.DSS';
%% Compilng 8500 Node system
% DSSText.command='Compile  D:\OpenDSS\OpenDSS\IEEETestCases\8500-Node\Master-unbal.dss';
% DSSText.command='Set mode=daily stepsize=1h number=1';
% DSSText.command='Redirect "D:\OpenDSS\OpenDSS\Examples\Loadshapes\Loadshapes1\loadshape_daily.DSS';
% DSSText.command='Redirect "C:\OpenDSS\Examples\Loadshapes\loadshape_daily.DSS"';
% DSSText.command='Batchedit load..* daily=loadshape_daily';
%% Compilng EPRI ckt 7
% DSSText.command='Set mode=daily stepsize=1h number=1';
% DSSText.command='Redirect "D:\OpenDSS\OpenDSS\Examples\Loadshapes\Loadshapes1\loadshape_daily.DSS';
% DSSText.command='Batchedit load..* daily=loadshape_daily';
%% Compilng EPRI ckt 24
% DSSText.command='Compile  D:\OpenDSS\OpenDSS\EPRITestCircuits\ckt24\master_ckt24.dss';
% DSSText.command='Set mode=yearly stepsize=1h number=1';
%% Setting parameters and extracting solution
% Check manual for details on control mode
DSSText.command='Set Controlmode=OFF';
DSSSolution.dblHour=0.0;
bus_names = DSSCircuit.AllNodenames;
Noofhours=1;
Meter_values_index=0;
tic
 [Bus,PDElement,PCElement,Transformertap,Switch] = Timestep(Noofhours,DSSText,DSSCircuit,DSSSolution,0,Meter_values_index);
toc
%% Generating load names for any system
load_name_select=1;
if(load_name_select)
    load_name=cell(size(PCElement,2),1);
    for i =1:size(PCElement,2)
        loadname_split=regexp(PCElement(i).name,'_','split');
        % EPRI 7 test system load names
        if(size(loadname_split,1) > 2)
            loadname_split(1,2)=strcat(loadname_split(1,2),'_',loadname_split(1,3));
        end
        load_name{i}=loadname_split{1,2};
    end
end
%% Assigning Loadshape using functions
xcelwrite=1;
if(xcelwrite)
    yearly_filename='C:\OpenDSS\Examples\Loadshapes\PCA_loadshape_assign\IEEE13loadshape.DSS';
    load('loadshape_names.mat');
    assign_loadshape(yearly_filename,load_name,loadshape_name);
end