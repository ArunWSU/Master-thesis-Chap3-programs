function assign_loadshape(yearly_filename,load_name,loadshape_name)
% Assigning loadshape for each of loads copying for quickness instead of functions
assign_yearly_loads=yearly_filename;
fid=fopen(assign_yearly_loads,'w');
str1='Redirect "C:\OpenDSS\Examples\Loadshapes\Dataid_annual_loadshape\yearly_load_shape.DSS"';
fprintf(fid, '%s \r', str1);
fclose(fid);
% Load names should be a vertical file
for i=1:size(load_name,1)
    c= strcat('Edit Load.',num2str(load_name{i}),' yearly=',loadshape_name{randi(35)}); % No of loadshapes(35) 
    fid=fopen(assign_yearly_loads,'at');
    fprintf(fid,'\n %s',c);
    fclose(fid);
end
end