%% Extracting all data from different IEEE distribution test systems
% Setting up openDSS interface
% Initialize OpenDSS
DSSObj = actxserver('OpenDSSEngine.DSS'); % Instantiate the OpenDSSEnigne
DSSStart=DSSObj.Start(0); % start Open DSS by zero

% Start up the SolverArunge
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
%% Compiling different test system
% Choice of test system: scroll this subsection or modify for new system 
test_system='13';
DSSText.Command='Clear';
Meter_values_index=0;
Noofhours=24;
daily=0;
switch(test_system)
    case '123'
        if(daily==1)
            DSSText.Command='Compile (D:\OpenDSS\OpenDSS\IEEETestCases\123Bus - Copy\IEEE123Master.DSS)';
            DSSText.Command='Compile (C:\OpenDSS\OpenDSS\IEEETestCases\123Bus - Copy -cloud\IEEE123Master.dss)';
        else
            DSSText.Command='Compile C:\OpenDSS\IEEETestCases\123Bus\IEEE123Master.dss';
            DSSText.Command='Set Mode=yearly stepsize=15m number=1';
            DSSText.Command='Redirect C:\OpenDSS\Examples\Loadshapes\PCA_loadshape_assign\IEEE123loadshape.dss';
        end
    case '13'
        DSSText.command='Compile  "C:\OpenDSS\IEEETestCases\13Bus\IEEE13Nodeckt.dss"';
        DSSText.command='Set mode=yearly stepsize=15m number=1';
        DSSText.command='Redirect "C:\OpenDSS\Examples\Loadshapes\PCA_loadshape_assign\IEEE13loadshape.DSS"';
    case '13sec'
        Meter_values_index=[13,19,23,24,27,28,33,34];
        DSSText.command='Compile  D:\OpenDSS\OpenDSS\IEEETestCases\13Bus_Secondary\TestwithoutPV.dss';
        DSSText.command='Set mode=yearly stepsize=15m number=1';
        DSSText.command='Redirect D:\OpenDSS\OpenDSS\Examples\Loadshapes\Dataid_annual_loadshape\IEEE13secloadshape.DSS';
    case '342'
        DSSText.command='Compile  D:\OpenDSS\OpenDSS\IEEETestCases\LVTestCaseNorthAmerican\Master.DSS';
        DSSText.command='Set mode=yearly stepsize=15m number=1';
        DSSText.command='Redirect D:\OpenDSS\OpenDSS\IEEETestCases\LVTestCaseNorthAmerican\AssignLoadshapeYearly.DSS';
    case '240'
        DSSText.command='Compile  D:\OpenDSS\OpenDSS\IEEETestCases\RealDistfeeder\Master.DSS';
        DSSText.command='Set mode=yearly stepsize=15m number=1';
        DSSText.command='Redirect D:\OpenDSS\OpenDSS\Examples\Loadshapes\Dataid_annual_loadshape\IEEE240rand.DSS';
        DSSText.command='Batchedit load..* yearly=loadshape_yearly1';
    case '8500'
        DSSText.command='Compile  D:\OpenDSS\OpenDSS\IEEETestCases\8500-Node\Master-unbal.dss';
        DSSText.command='Set mode=yearly stepsize=15m number=1';
        DSSText.command='Redirect D:\OpenDSS\OpenDSS\Examples\Loadshapes\Dataid_annual_loadshape\Yearly8500loadshape.DSS';
    case 'LVtest'
        DSSText.command='Compile  D:\OpenDSS\OpenDSS\IEEETestCases\LVTestCase\Master.dss';
        DSSText.command='Set mode=yearly stepsize=15m number=1';
    case 'Epri7'   
        DSSText.command='Compile  D:\OpenDSS\OpenDSS\EPRITestCircuits\ckt7\Master_ckt7.dss';
        DSSText.command='Set mode=yearly stepsize=1h number=1';
        DSSText.command='Redirect "D:\OpenDSS\OpenDSS\Examples\Loadshapes\Loadshapes1\loadshape_daily.DSS';
        DSSText.command='Batchedit load..* daily=loadshape_daily';
    case 'Epri7random'   
        DSSText.command='Compile D:\OpenDSS\OpenDSS\EPRITestCircuits\ckt7\Master_ckt7.dss';
        DSSText.command='Set mode=yearly stepsize=1h number=1';
        DSSText.command='Redirect D:\OpenDSS\OpenDSS\Examples\Loadshapes\Dataid_annual_loadshape\EPRI7loadshape.DSS';
    case 'Epri24def'
        DSSText.command='Compile  D:\OpenDSS\OpenDSS\EPRITestCircuits\ckt24\master_ckt24.dss';
        DSSText.command='Set mode=yearly stepsize=1h number=1';
        DSSText.command='Redirect D:\OpenDSS\OpenDSS\EPRITestCircuits\ckt24\AssignLoadshapeYearly.DSS';
    case 'Epri24random'
        DSSText.command='Compile  D:\OpenDSS\OpenDSS\EPRITestCircuits\ckt24\master_ckt24.dss';
        DSSText.command='Set mode=yearly stepsize=1h number=1';
        DSSText.command='Redirect D:\OpenDSS\OpenDSS\Examples\Loadshapes\Dataid_annual_loadshape\EPRI24loadshape.DSS';
end
%% Extracting data from system
DSSText.command='Set Controlmode=OFF';
DSSSolution.dblHour=0.0;
tic
[Bus,PDElement,PCElement,Transformertap,Switch] = Timestep(Noofhours,DSSText,DSSCircuit,DSSSolution,0,Meter_values_index);
toc
PD_loss_P_matrix_sum=sum(PDElement(1).PD_loss_P_matrix,2);
PD_Tloss_P_matrix_sum=sum(PDElement(1).PD_Tloss_P_matrix,2);