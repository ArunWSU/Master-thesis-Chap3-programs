function [Bus,PDElement,PCElement,Transformertap,Switch] = Timestep(Noofhours,DSSText,DSSCircuit,DSSSolution,FaultFlag,Meter_values_index)
% Solves the circuit for one timestep and extracts specified values
t1=1;
[PDElement,PCElement,Noregflag,Noswitchflag]=deal(zeros(1));
if(FaultFlag==1)
        DSSText.Command='New Fault.F1   Phases=1  Bus1=110.1 OnTime=2 temporary=yes repair=0.2'; % Gmatrix=? R=? min amps=?
end
DSSCircuit.Loads.First;
a(1,1)=DSSCircuit.Loads.KW;
a(1,2)=DSSCircuit.Loads.Kvar;
while(DSSSolution.dblHour <= Noofhours) % 4 Datapoints hour 2 months 720
DSSText.command='CktLosses';
DSSSolution.Solve;
Tloss(t1,:)=str2num(DSSText.Result);
if(Meter_values_index~=0)
    Meter_array=zeros(size(Meter_values_index,2),1);
    for i=1:size(Meter_values_index,2)
        Meter_array(i,1)=DSSCircuit.Meters.RegisterValue(Meter_values_index(i));
    end
    Meter_matrix(t1,:)=Meter_array;
end
Bus.V(t1,:)=DSSCircuit.AllBusVmag;
Bus.Vpu(t1,:)=DSSCircuit.AllBusVmagpu;
Bus.Volt_all(t1,:)=DSSCircuit.AllBusVolts;
Bus.Node_names=DSSCircuit.AllNodeNames;
[PCElement] = Dataextract(PCElement,DSSCircuit,'FirstPCElement','NextPCElement',t1,0); % Last argument specifies loss calculation
[PDElement] = Dataextract(PDElement,DSSCircuit,'FirstPDElement','NextPDElement',t1,1);
i=DSSCircuit.Regcontrol.First;
if(i~=1)
    Noregflag=1;
end
while(i > 0)
       if(t1==1)
        Tap_header(t1,i)={DSSCircuit.Regcontrol.name};
       end
        Tap_values(t1,i)={DSSCircuit.Regcontrol.TapNum};
i=DSSCircuit.Regcontrol.Next;
end
i=DSSCircuit.Swtcontrol.First;
if(i~=1)
    Noswitchflag=1;
end
while(i > 0)
    if(t1==1)
        Switch_names(t1,i)={DSSCircuit.Swtcontrol.name};
    end  
%         if(strcmp(Switch_names{1,i},'switch5'))
%             fprintf('\n In loop');
%             DSSCircuit.Swtcontrol.action=0;
%         end
        Switch_values(t1,i)={DSSCircuit.Swtcontrol.state};      
% Switch(t1).(DSSCircuit.Swtcontrol.name)=DSSCircuit.Swtcontrol.state;
i=DSSCircuit.Swtcontrol.Next;
end
Time(t1,1)={DSSSolution.dblHour};
t1=t1+1;
% fprintf('\n Current hour is %d',DSSSolution.dblHour)
end
PDElement(1).Totalloss=Tloss;
if(Meter_values_index~=0)
    PDElement(1).Meter_mat=Meter_matrix;
end
Transformertap=[];
Switch=[];
Bus.timestamp=Time;
Time_cell=[{'Time_hour'}; Bus.timestamp];
if(Noregflag~=1)
    Transformertap=[Time_cell [Tap_header;Tap_values]];    
end
if(Noswitchflag~=1)
    Switch=[Time_cell [Switch_names;Switch_values]];
end
end

