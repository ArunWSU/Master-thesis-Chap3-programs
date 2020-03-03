function [Timestep_Array,Store_Matrix] = Arraystore(i,j,t1,Element_value,Timestep_Array,Store_Matrix)
% Creates an matrix of system for each time step
   % Single Timestep array
   if(i==1) 
       Timestep_Array=Element_value;
   else           
       Timestep_Array=[Timestep_Array Element_value];
   end
   % Matrix formation 
   if(j==0)  
       if(t1==1)
         Store_Matrix=Timestep_Array;
       else
         Store_Matrix(t1,:)=Timestep_Array;
       end
   end
end