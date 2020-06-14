'''
Created on Tue Dec  3 16:00:20 2019

@author: WSU-PNNL
'''
#%% Section to write csv
import os
import pandas as pd
import json
import numpy as np
from matplotlib import pyplot as plt
from matplotlib.ticker import StrMethodFormatter

# Each message in 3s time interval.

#0. Primary Load 1. Primary Bus voltages  
bus_voltages=1
#file_path='C:\PCAdatasets'
file_path=(r'C:\Users\insti\OneDrive - Washington State University (email.wsu.edu)\Programs\MATLAB programs\PCA research project\PCA processing programs\Batch PCA json files')
input_file="volt_123pv_June_8_houses.json"
input_file=os.path.join(file_path,input_file)
excel_write=1
phase='A'
out_phase=".1"
output_file='IEEE123PV_Bus_V_GRIDAPPSD_June_8.xlsx'
# Message write count of 30 for June 6 file

## Obtain Measurement id of objects
#with open("ACLineseg_MRID_123pv.json","r") as json_file:
#    obj_msr_id=json.load(json_file)


### Sample Data files
#with open("volt_123pv_line.json","r") as json_file:
#    sample_data=json.load(json_file)

#input_file="response.json"
#with open(input_file,"r") as json_file:
#    sample_data=json.load(json_file)

#%% Primary load voltages
### Load complete data     
if(bus_voltages==0):
    with open("voltage_123pv_3hr_data_Jan_24_app3.json","r") as json_file:
        complete_PNV=json.load(json_file)
    
    x=complete_PNV[0]
    
    d=[]
    for idx,val in enumerate(x):
        if(idx!=0):
            d.append(val['bus'])
            
    sec_comparison=[int(x[0][0]!='s') for x in d]
    primary_nodes=np.where(sec_comparison)[0]
    primary_node_names=[x[i]['bus'] for i in primary_nodes+1]
    E=[x[i]['PNV'][0] for i in primary_nodes+1]
    
    X=[]
    for idx,val in enumerate(complete_PNV):
        E=[val[i]['PNV'][0] for i in primary_nodes+1]
        X.append(E)
    volt_prim_load_all=np.array(X).reshape(-1,len(E))
    volt_prim_load_phase_A=np.hstack((volt_prim_load_all[:,1].reshape(-1,1),(volt_prim_load_all[:,1:-1:3])))
    volt_prim_load_phase_A_names=[primary_node_names[0]]+primary_node_names[1:-1:3]
    A=pd.DataFrame(data=volt_prim_load_phase_A,columns=volt_prim_load_phase_A_names)
    if(excel_write):
           A.to_excel("volt_123pv_prim_loads.xlsx")
#%% ACLineSegment Simulation
else:
    with open(input_file,"r") as json_file:
        Bus_V_line=json.load(json_file)
    
    # Bus names
    First_time_V=Bus_V_line[0][1:-1]
    Bus_names=[str(x['bus']) for x in First_time_V]
    phase_index=np.where([int(x['Phase']==phase) for x in First_time_V])[0]
    
    # Generating Excel file by phases
    Bus_ph_names=[Bus_names[y] for y in phase_index]
    Bus_ph_names_1=[]
    for idx, val in enumerate(Bus_ph_names):
        Bus_ph_names_1.append(val+(out_phase))
    
    Bus_val_list=[]
    for idx,val in enumerate(Bus_V_line):
        One_timestep_V=[val[i]['PNV'][0] for i in phase_index+1]
        Bus_val_list.append(One_timestep_V)
    volt_prim_Bus_ph=np.array(Bus_val_list).reshape(-1,len(One_timestep_V))
    output_V_df=pd.DataFrame(data=volt_prim_Bus_ph,columns=Bus_ph_names_1)
    if(excel_write):
       output_V_df.to_excel(output_file,index=False)
    
    # Plotting single bus voltage
    volt_variation=volt_prim_Bus_ph[:,0]
    plt.plot(volt_variation)
    plt.gca().yaxis.set_major_formatter(StrMethodFormatter('{x:,.2f}'))
    plt.xlabel('Time step (30s duration)')
    plt.ylabel('Voltage (V) of Bus'+ str(Bus_ph_names[0]))
    plt.tight_layout()
    plt.show()
    plt.savefig("Bus_"+str(Bus_ph_names[0])+".png")
    
# Ref for decimal places in plot: https://stackoverflow.com/questions/29188757/matplotlib-specify-format-of-floats-for-tick-labels
# Label cut off: https://stackoverflow.com/questions/6774086/why-is-my-xlabel-cut-off-in-my-matplotlib-plot





