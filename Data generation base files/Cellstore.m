function [struct] = Cellstore(struct,t1,i,Element_value,fldname)
% Cell store stores it to corresponding elements
if(t1==1)
           struct(i).(fldname)={Element_value};
       else
           struct(i).(fldname)={[struct(i).(fldname){1,1};Element_value]};
end
end

