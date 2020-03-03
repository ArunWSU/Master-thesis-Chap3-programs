function [P_power,Q_power]=powersplit(i,PDElement_Power,PDElement,P_power,Q_power)
% Splits only forward (terminal 1) S into P and Q arrays
       P=PDElement_Power(1:2:PDElement(i).NoofConductors);
       Q=PDElement_Power(2:2:PDElement(i).NoofConductors);
           if(i==1)
               P_power=P;
               Q_power=Q;
           else
               P_power=[P_power P];
               Q_power=[Q_power Q];
           end
end

