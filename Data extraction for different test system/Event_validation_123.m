%% Event validation cases 
%Initialize OpenDSS
DSSObj = actxserver('OpenDSSEngine.DSS'); % Instantiate the OpenDSSEnigne
DSSStart=DSSObj.Start(0); % start Open DSS by zero

% Start up the Solver
if DSSStart
    disp('Connection Established');
else
    disp('Unable to start the OpenDSS Engine')
end

% Set up the Text, Circuit, and Solution   Interfaces
DSSText = DSSObj.Text;
DSSCircuit = DSSObj.ActiveCircuit; 
DSSSolution = DSSCircuit.Solution;
DSSCtrlQueue=DSSCircuit.CtrlQueue;
DSSText.Command='Clear';
loadshape_rand=1;

%% Select base Master file depending on the use case
% For Daily Simulation
DSSText.Command='Compile D:\OpenDSS\OpenDSS\IEEETestCases\123Bus\IEEE123Master.dss';

% Topology changes Switch 7 closed 1: Switch 3 open, 2: Switch 5 open
% DSSText.Command='Compile D:\OpenDSS\OpenDSS\IEEETestCases\123Bus\IEEE123Master_Topo_1.dss';
% DSSText.Command='Compile D:\OpenDSS\OpenDSS\IEEETestCases\123Bus\IEEE123Master_Topo_2.dss';

% Capacitor changes
% DSSText.Command='Compile D:\OpenDSS\OpenDSS\IEEETestCases\123Bus\IEEE123Master_Capa_miss.dss';

if(loadshape_rand) 
    DSSText.Command='Set Mode=yearly stepsize=15m number=1';
    DSSText.Command='Redirect D:\OpenDSS\OpenDSS\Examples\Loadshapes\Dataid_annual_loadshape\IEEE123loadshape.DSS';
else
    DSSText.Command='Set Mode=Daily stepsize=1h number=1';
    DSSText.Command='Redirect D:\OpenDSS\OpenDSS\IEEETestCases\123Bus\SetDailyLoadShape.DSS';
end
Meter_values_index=0;
% DSSSolution.InitSnap; % To initialize rhe monitors if it exists
%% Regulator and Topology change cases
DSSSolution.dblHour=0.0;
use_case=0;
Noofhours=24;
switch use_case
    case 0
        % Case 0 No regulator controls
        DSSText.Command='Set Controlmode=OFF';
    case 1
        % Case 1 Regulator controls 
        DSSText.Command='Set Controlmode=Time';
        % Case 2 Reconfiguration (Sequence number and no reg actiom)
    case 21
        DSSText.Command='Set Controlmode=Time';
        DSSText.Command='SwtControl.Switch5.Action=Open';
        DSSText.Command='SwtControl.Switch7.Action=Close';
    case 22
        DSSText.Command='Set Controlmode=Static';
        DSSText.Command='SwtControl.Switch3.Action=Open';
        DSSText.Command='SwtControl.Switch7.Action=Close';
    case 23
        DSSText.Command='Set Controlmode=Time';
        DSSText.Command='SwtControl.Switch4.Action=Open';
        DSSText.Command='SwtControl.Switch7.Action=Close';
end
tic
[Bus,PDElement,PCElement,Transformertap,Switch] = Timestep(Noofhours,DSSText,DSSCircuit,DSSSolution,0,Meter_values_index);
toc 
if(use_case==3)
    Noofhours=20;
    DSSText.Command='Edit Fault.F1 Enable=no';
    [Bus1,PDElement1,PCElement1,Transformertap1,Switch1] = Timestep(Noofhours,DSSText,DSSCircuit,DSSSolution,0,Meter_values_index);
end