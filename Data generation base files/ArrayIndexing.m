function [Element_Struct,ElementSize] = ArrayIndexing(i,Indexflag,Element_value,Element_Struct,ElementSize,fieldname,prop)
% Array indexing creates index for different elements of array store
if(Indexflag==1)
    a=Element_Struct(i).(prop){1,1};
else
    a=Element_value;
end
    ElementSize(i)=size(a,2);
   if(i==1) 
        Element_Struct(i).(fieldname)=1;
   else
        Space=ElementSize(i-1);
        Element_Struct(i).(fieldname)=Element_Struct(i-1).(fieldname)+Space;
   end
end

