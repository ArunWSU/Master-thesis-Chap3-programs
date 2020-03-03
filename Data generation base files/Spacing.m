function [ Mult ] = Spacing(k,Element_value,Element_Struct)
% Spacing between start array indices
    if(((size(Element_value,2))/4)==(Element_Struct(k).NoofConductors))
                  Mult=4;
    else
                  Mult=2;
    end
end

