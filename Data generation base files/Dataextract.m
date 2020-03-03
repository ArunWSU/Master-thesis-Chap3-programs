function [PDElement] = Dataextract(PDElement,DSSCircuit,fldname,nextfield,t1,Losscalcflag)
%Stores Apparent power, Real power and current
%Depends on cellstore, ArrayIndexing and Arraystore
j=DSSCircuit.(fldname);
i=1;
% Cannot assign a struct to zero initialized one
if(i==1)&&(t1==1)
    clear PDElement;
end
% First time step initialize to zero else obtain exisiting value from PDElement struct
[PD_S_Timestep_Array,PD_S_matrix,PD_P_Timestep_Array,PD_P_matrix,PD_Q_Timestep_Array,PD_Q_matrix,Id_Timestep_Array,Id_matrix,PDElementSize,PElementSize,IElementSize,Id1_matrix,Id1_Timestep_Array]=deal(zeros(1));
if(Losscalcflag==1)
    [PD_loss_Timestep_Array,PD_loss_matrix,PlossElementSize,PD_loss_P_Timestep_Array,PD_loss_P_matrix,PlossPElementSize,PD_Tloss_P_Timestep_Array,PD_Tloss_P_matrix,PTlossPElementSize]=deal(zeros(1));
    if(t1~=1)
        PD_loss_matrix=PDElement(1).PD_loss_matrix;
        PD_loss_P_matrix=PDElement(1).PD_loss_P_matrix;
        PD_Tloss_P_matrix=PDElement(1).PD_Tloss_P_matrix;
    end
end
if(t1~=1) 
    PD_S_matrix=PDElement(1).Smatrix;
    PD_P_matrix=PDElement(1).Pmatrix;
    PD_Q_matrix=PDElement(1).Qmatrix;
    Id_matrix=PDElement(1).Imatrix;
    Id1_matrix= PDElement(1).Ipmatrix;
end
% Parse through till the end of last element and obtain values
while(j~=0)
       Multiplier2=1*10^(-3);
       PDElement(i).name=DSSCircuit.Activecktelement.Displayname;
       PDElement(i).NoofPhases=DSSCircuit.Activecktelement.NumPhases;
       PDElement(i).NoofConductors=DSSCircuit.Activecktelement.NumConductors;
       PDElement_S=DSSCircuit.ActivecktElement.Powers;
       PDElement_Current=DSSCircuit.ActivecktElement.currents;
       PD_power=PDElement_S(1:2:2*PDElement(i).NoofPhases);
       QD_power=PDElement_S(2:2:2*PDElement(i).NoofPhases);
       Modified_I=PDElement_Current(1:1:2*PDElement(i).NoofPhases);
       j=DSSCircuit.(nextfield); 
       [PDElement] = Cellstore(PDElement,t1,i,PDElement_S,'power');
       [PDElement] = Cellstore(PDElement,t1,i,PDElement_Current,'current');
       if(t1==1)
           [PDElement,PDElementSize] = ArrayIndexing(i,1,PDElement_S,PDElement,PDElementSize,'Sindex','power');
           [PDElement,PElementSize] = ArrayIndexing(i,0,PD_power,PDElement,PElementSize,'Pindex','power');
           [PDElement,IElementSize] = ArrayIndexing(i,0,PDElement_Current,PDElement,IElementSize,'Iindex','current');
       end
       [PD_P_Timestep_Array,PD_P_matrix] = Arraystore(i,j,t1,PD_power,PD_P_Timestep_Array,PD_P_matrix);
       [PD_Q_Timestep_Array,PD_Q_matrix] = Arraystore(i,j,t1,QD_power,PD_Q_Timestep_Array,PD_Q_matrix);
       [PD_S_Timestep_Array,PD_S_matrix] = Arraystore(i,j,t1,PDElement_S,PD_S_Timestep_Array,PD_S_matrix);
       [Id_Timestep_Array,Id_matrix] = Arraystore(i,j,t1,PDElement_Current,Id_Timestep_Array,Id_matrix);
       [Id1_Timestep_Array,Id1_matrix] = Arraystore(i,j,t1,Modified_I,Id1_Timestep_Array,Id1_matrix);
       if(Losscalcflag==1)
            PDElement_PhaseLoss=DSSCircuit.ActivecktElement.PhaseLosses;
            PDElement_TotLoss=(DSSCircuit.ActivecktElement.Losses)*Multiplier2;
            n=size(PDElement_PhaseLoss,2);
            if(n==2)
                PDElement_P_PhaseLoss=PDElement_PhaseLoss(1);
            else
                PDElement_P_PhaseLoss=PDElement_PhaseLoss(1:2:n);
            end
            [PDElement] = Cellstore(PDElement,t1,i,PDElement_PhaseLoss,'loss');
            [PDElement] = Cellstore(PDElement,t1,i,PDElement_TotLoss,'Tloss');
            if(t1==1)
                [PDElement,PlossElementSize] = ArrayIndexing(i,0,PDElement_PhaseLoss,PDElement,PlossElementSize,'Plossindex','loss');
                [PDElement,PlossPElementSize] = ArrayIndexing(i,0,PDElement_P_PhaseLoss,PDElement,PlossPElementSize,'PlossPindex','loss');
            end
            [PD_loss_Timestep_Array,PD_loss_matrix] = Arraystore(i,j,t1,PDElement_PhaseLoss,PD_loss_Timestep_Array,PD_loss_matrix);
            [PD_loss_P_Timestep_Array,PD_loss_P_matrix] = Arraystore(i,j,t1,PDElement_P_PhaseLoss,PD_loss_P_Timestep_Array,PD_loss_P_matrix);
            [PD_Tloss_P_Timestep_Array,PD_Tloss_P_matrix] = Arraystore(i,j,t1,PDElement_TotLoss(:,1),PD_Tloss_P_Timestep_Array,PD_Tloss_P_matrix);
       end
       i=i+1;
end 
 % update the PDElement struct with new values
    PDElement(1).Smatrix=PD_S_matrix;
    PDElement(1).Pmatrix=PD_P_matrix;
    PDElement(1).Qmatrix=PD_Q_matrix;
    PDElement(1).Imatrix=Id_matrix;
    PDElement(1).Ipmatrix=Id1_matrix;
    if(Losscalcflag==1)
        PDElement(1).PD_loss_matrix= PD_loss_matrix;
        PDElement(1).PD_loss_P_matrix=PD_loss_P_matrix;
        PDElement(1).PD_Tloss_P_matrix=PD_Tloss_P_matrix;
    end
end
