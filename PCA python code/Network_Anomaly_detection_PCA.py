"""
Created on Sun Jul 21 12:53:05 2019
@author: Arun
"""
# Package dependencies
import os
import pandas as pd
import numpy as np
import random
from sklearn.decomposition import PCA
from matplotlib import pyplot as plt
import seaborn as sns
#%% Reading PCA input data
# Variables to set phase(0-A,1-B,2-C)
# Visualization and saving figure to 1
phase=0
visualize_fig=1
save_fig=0

# Figure path to save 
#figure_path='C:\Test system results'
figure_path=(r'C:\Users\insti\OneDrive - Washington State University (email.wsu.edu)\Programs\MATLAB programs\PCA research project\PCA plots and results\Applying PCA\GRID_APPS_D')
fig_extension='.png'
# Minimum dpi 300 for conference images, increases size of image
fig_dpi=300

# Input file
model_name='IEEE123PV_Bus_V_GRIDAPPSD_June_8' 
#model_name='IEEE123PV_Bus_V_GRIDAPPSD_June_8','EPRI_ckt24prim_randomvolt', 'Bus_8500_randomvolt' 
excel_file_path='C:\PCAdatasets'
file_name=model_name

file=os.path.join(excel_file_path,file_name)
volt_phase_pca_inp=pd.read_excel((file+'.xlsx'),phase)
bus_names=list(volt_phase_pca_inp.columns)
noise=np.random.normal(0,0.0,size=(volt_phase_pca_inp.shape[0],volt_phase_pca_inp.shape[1]))
volt_phase_pca_inp=volt_phase_pca_inp+noise
#%% Matrix visualization
# Function to visualize line plots
def gen_line_plot(x,y,label_x,label_y,visualize_fig,save_fig,fig_name,file_name,file_path):
    if(visualize_fig):
        plt.figure()
        plt.plot(x,y,linewidth=1, marker='o',markersize=3)
        plt.xlabel(label_x)
        plt.ylabel(label_y)
        plt.tight_layout()
        plt.show()
        if(save_fig==1):
            plt.savefig(os.path.join(file_path,fig_name+file_name+'.png'))
            # IEEE Paper submission
            # plt.savefig(os.path.join(file_path,fig_name+file_name+'.eps'),format='eps',dpi=600)

idx=volt_phase_pca_inp.columns.values
#data=volt_phase_pca_inp.loc[:,idx[0:100]]
data=volt_phase_pca_inp

# Row and column visualizations of observation matrix
x=np.arange(0,data.shape[1])
gen_line_plot(x,data.T,'Different nodes of the system (Line - profile for different time steps)','Voltage (pu)',visualize_fig,save_fig,'Voltage visualization 2',file_name,figure_path)

x=np.arange(0,data.shape[0])
gen_line_plot(x,data,'No of time steps (Line-Different nodes)','Voltage (pu)',visualize_fig,save_fig,'Voltage visualization 1',file_name,figure_path)
save_fig=0
#%% Determine No of principal components 'n'
i=7
PCA_full_check=PCA(n_components=i)
subspace_full_check=PCA_full_check.fit_transform(volt_phase_pca_inp)

# Find the perecentage of information it holds
for n in range(1,i):
    variance_captured=PCA_full_check.explained_variance_ratio_[0:n].sum()*100
    if(variance_captured > 98):
        break
#%% Subspace projection of whole dataset
PCA_full=PCA(n_components=n)
subspace_full=PCA_full.fit_transform(volt_phase_pca_inp)
model_name=model_name+'components_'+str(n)
reconstructed_full=PCA_full.inverse_transform(subspace_full)
diff_full=reconstructed_full-volt_phase_pca_inp

label_names=['Subspace value 0','Subspace value 1','Subspace value 2']
if(n==1):
    label_names='Sub-space representation of whole dataset'

visualize_fig=0
# Visualizing the projection of whole dataset
if(visualize_fig):
    plt.figure()
    x=np.arange(0,volt_phase_pca_inp.shape[0])
    for i in range(subspace_full.shape[1]):
      plt.plot(x,subspace_full[:,i],label=label_names[i])
    plt.xlabel('Time step')
    plt.ylabel('Sub space values')
    plt.legend()
    plt.show()
    if(save_fig==1):
        plt.savefig(os.path.join(figure_path,'Subspace projection full'+ model_name+'.png'),dpi=fig_dpi)
#%% Anomaly Detection: Training PCA model
# Train PCA 70% of the input dataset
single_data_file=1
train_percent=0.7
end_index=int(volt_phase_pca_inp.shape[0]*train_percent)
if(single_data_file):
    test_start=end_index
    Feeder1_train=volt_phase_pca_inp[0:end_index].copy()
else:
    test_start=0
    Feeder1_train=volt_phase_pca_inp

PCA_train=PCA(n_components=n)
subspace_train=PCA_train.fit_transform(Feeder1_train)
reconstructed_train=PCA_train.inverse_transform(subspace_train)
reconstructed_diff_train=Feeder1_train-reconstructed_train

# Test dataset Inserting anomalies
# Bus for anomaly use case 0 and 1 
#select_bus=bus_names[int(len(bus_names)/2)]
select_bus=bus_names[-1]

if(single_data_file==0):
    # IEEE 123 Test event validation
    model_name='IEEE_123_Capa_missvolt'
    file_name=model_name+'.xlsx'
    file=os.path.join(excel_file_path,file_name)
    volt_phase_pca_inp=pd.read_excel(file,phase)
    

# Case 1: Missing measurement
Feeder1_test1=volt_phase_pca_inp[test_start:].copy()
Feeder1_test1[select_bus].loc[end_index+1:end_index+3]=0
subspace_v1=PCA_train.transform(Feeder1_test1)
reconstructed_v1=PCA_train.inverse_transform(subspace_v1)
subspace_diff1=subspace_v1-PCA_train.transform(volt_phase_pca_inp[test_start:])
reconstructed_diff1=Feeder1_test1-reconstructed_v1

# Case 2 : Bad voltage measurement
Feeder1_test2=volt_phase_pca_inp[test_start:].copy()
#noise1=np.random.normal(0,0.03,size=(Feeder1_test2.shape[0],Feeder1_test2.shape[1]))
#Feeder1_test2=Feeder1_test2+noise1
volt_bad_meas=np.arange(0.9,1.1,0.01)
Feeder1_test2[select_bus].loc[end_index:end_index+3]=0.9
#Feeder1_test2[select_bus].loc[end_index:end_index+3]=random.sample(list(volt_bad_meas),1)[0]
subspace_v2=PCA_train.transform(Feeder1_test2)
subspace_diff2=subspace_v2-PCA_train.transform(volt_phase_pca_inp[test_start:])
reconstructed_v2=PCA_train.inverse_transform(subspace_v2)
reconstructed_diff2=Feeder1_test2-reconstructed_v2

# Use case 3:Multiple bad measurements
Feeder1_test3=volt_phase_pca_inp[test_start:].copy()
#noise2=np.random.normal(0,0.03,size=(Feeder1_test3.shape[0],Feeder1_test3.shape[1]))
#Feeder1_test3=Feeder1_test3+noise2
#rand_val=[0.9,0.9,0.9]
#buses_bad_data=[bus_names[-5],bus_names[-15],bus_names[-25]]
rand_val=random.sample(list(volt_bad_meas),3)
buses_bad_data=random.sample(bus_names,3)
buses_bad_data=['64.1','86.1','94.1']
Feeder1_test3[buses_bad_data[0]].loc[end_index+1]=rand_val[0]
Feeder1_test3[buses_bad_data[1]].loc[end_index+1]=rand_val[1]
Feeder1_test3[buses_bad_data[2]].loc[end_index+1]=rand_val[2]
subspace_v3=PCA_train.transform(Feeder1_test3)
subspace_diff2=subspace_v3-PCA_train.transform(volt_phase_pca_inp[test_start:])
reconstructed_v3=PCA_train.inverse_transform(subspace_v3)
reconstructed_diff3=Feeder1_test3-reconstructed_v3
reconstructed_actual_values=Feeder1_test2.loc[end_index+1]-reconstructed_diff3.loc[end_index+1]
#%% Check for maximum column is within tolerance 
i=7
PCA_single_anomaly=PCA(n_components=i)
subspace_single_anomaly=PCA_single_anomaly.fit_transform(Feeder1_test2)

# Determine No of principal components 'n' perecentage of information it holds
for n1 in range(1,i):
    variance_captured=PCA_single_anomaly.explained_variance_ratio_[0:n1].sum()*100
    if(variance_captured > 98):
        break
    
PCA_multiple_anomaly=PCA(n_components=i)
subspace_multiple_anomaly=PCA_multiple_anomaly.fit_transform(Feeder1_test3)

# Determine No of principal components 'n' perecentage of information it holds
for n2 in range(1,i):
    variance_captured=PCA_multiple_anomaly.explained_variance_ratio_[0:n2].sum()*100
    if(variance_captured > 98):
        break
#%% Visualzing the PCA anomaly test cases
visualize_fig=1
if(visualize_fig):
    #Train and test data visualization
    label_names=['Training data','Single missing data','Single Bad data']
    plt.figure()
    plt.plot(Feeder1_train.index.values,subspace_train,label=label_names[0])
    plt.plot(Feeder1_test1.index.values,subspace_v1,label=label_names[1])
    plt.plot(Feeder1_test2.index.values,subspace_v2,label=label_names[2])
    plt.xlabel('Time steps')
    plt.ylabel('Sub space values')
    plt.legend()
    plt.show()
    if(save_fig):
        plt.savefig(os.path.join(figure_path,str(select_bus)+'Subspace diff voltage dev'+ model_name+'.png'),dpi=fig_dpi)
    
    # Subspace difference of use case 1 & 2
    label_names=['Missing data','Single Bad data']
    plt.figure()
    plt.plot(subspace_diff1,label=label_names[0])
    plt.plot(subspace_diff2,label=label_names[1])
    plt.xlabel('Time steps')
    plt.ylabel('Subspace Difference')
    plt.legend()
    plt.show()
    if(save_fig):
        plt.savefig(os.path.join(figure_path,str(select_bus)+'Subspace diff'+ model_name+'.png'),dpi=fig_dpi)
            

    # Reconstructed difference matrix of use case 1
    plt.figure()
    plt.plot(reconstructed_diff1)
    plt.xlabel('Time steps')
    plt.ylabel('Residuals for all nodes for single missing measurement')
    plt.show()
    if(save_fig):
        plt.savefig(os.path.join(figure_path,'Matrix case 2'+ model_name+'.png'),dpi=fig_dpi)
       
        
    # Reconstructed difference matrix of use case 2
    plt.figure()
    plt.plot(reconstructed_diff2)
    plt.xlabel('Time steps')
    plt.ylabel('Residuals of all nodes for single bad measurement')
    plt.show()
    if(save_fig):
        plt.savefig(os.path.join(figure_path,'Matrix case 3'+ model_name+'.png'),dpi=fig_dpi)
    
     # Reconstructed difference matrix of use case 3
    plt.figure()
    plt.plot(reconstructed_diff3)
    plt.ylabel('Residuals for all nodes for multiple bad data')
    plt.xlabel('Time steps')
    plt.show()
    if(save_fig):
        plt.savefig(os.path.join(figure_path,'Multiple bad data values'+ model_name+fig_extension),dpi=fig_dpi)
        
    # Reconstructed voltage difference of one node
    plt.figure()
    plt.plot(diff_full[bus_names[1]],label='Original data'+str(select_bus))
    plt.plot(reconstructed_diff1[bus_names[1]],label='Missing data')
    plt.plot(reconstructed_diff2[bus_names[1]],label='Single Bad data')
    plt.xlabel('Time steps')
    plt.ylabel('Residual of one node')
    plt.legend()
    plt.show()
    if(save_fig):
        plt.savefig(os.path.join(figure_path,str(select_bus)+'Voltage dev'+ model_name+'.png'),dpi=fig_dpi)       
#%% Heat map visualizations of use cases
visualize_fig=1
#cols=reconstructed_diff2.columns.values[0:100]
cols=reconstructed_diff2.columns.values[-100:]
save_fig=1
color_map="Accent"
if(visualize_fig):
    # use case 1   
    plt.figure()
    ax=sns.heatmap(reconstructed_diff1[cols],cmap=color_map,xticklabels=10, yticklabels=3)
    ax.set(xlabel='First 200 Nodes: phase a',ylabel='Time instant:15 min stepsize')
    plt.tight_layout()
    plt.show()
    if(save_fig):
            plt.savefig(os.path.join(figure_path,'Residual_single_missing_measurement_1'+model_name+fig_extension),dpi=fig_dpi)
    
   # use case 2 
    plt.figure()
    ax=sns.heatmap(reconstructed_diff2[cols], cmap=color_map,xticklabels=10, yticklabels=3)
    ax.set(xlabel='First 200 Nodes: phase a',ylabel='Time instant:15 min stepsize')
    plt.tight_layout()
    plt.show()
    if(save_fig):
        plt.savefig(os.path.join(figure_path,'Residual_single_bad_measurement_1'+model_name+fig_extension),dpi=fig_dpi)
        
    # use case 3
    plt.figure()
    ax=sns.heatmap(reconstructed_diff3[cols], cmap=color_map,xticklabels=2, yticklabels=3, center=0)
    #ax=sns.heatmap(reconstructed_diff3[cols], xticklabels=2, yticklabels=3, center=0,cmap=color_map,vmin=min((reconstructed_diff3).min()), vmax=max(abs(reconstructed_diff3).max()))
    ax.set(xlabel='First 200 Nodes: phase a',ylabel='Time instant:15 min stepsize')
    plt.tight_layout()
    plt.show()
    if(save_fig):
        plt.savefig(os.path.join(figure_path,'Residuals_multiple_bad_measurements2'+model_name+fig_extension),dpi=fig_dpi)

    if(single_data_file==0): 
        # Event validation plot for simultaneous topology and residual change      
        reconstructed_70_split=reconstructed_diff_train.append(reconstructed_diff3)
        plt.figure()
        plt.plot(reconstructed_70_split)
        plt.ylabel('Residuals for all nodes for multiple bad data')
        plt.xlabel('Time steps')
        plt.show()
    
        # Residual matrix First order difference
        residual_diff=reconstructed_diff3.diff(axis=0).dropna()
        plt.figure()
        n=50
        plt.plot(residual_diff[0:n])
        plt.xticks(np.arange(0,n, 2.0))
        plt.xlabel('Timestep')
        plt.ylabel('Residual(pu)')
        plt.show()
        if(save_fig):
                plt.savefig(os.path.join(figure_path,'Residual matrix difference'+ model_name+'.png'),dpi=fig_dpi)
#%% Different degree of badness for single input
diff_degree=0
if(diff_degree):
    Feeder1_test4=volt_phase_pca_inp[test_start:].copy()
    recons_diff_period=[0]*np.shape(volt_bad_meas)[0]
    recons_diff_val=np.zeros(np.shape(volt_bad_meas)[0])
    for i,val in enumerate(volt_bad_meas):
        Feeder1_test4[select_bus].loc[end_index:end_index+3]=val
        subspace_v4=PCA_train.transform(Feeder1_test4)
        reconstructed_v4=PCA_train.inverse_transform(subspace_v4)
        reconstructed_diff4=Feeder1_test4-reconstructed_v4
        recons_diff_period[i]=reconstructed_diff4.loc[end_index:end_index+3]
        recons_diff_val[i]=reconstructed_diff4[select_bus].loc[end_index]     
    
    # Plotting the difference 
    actual_value=(volt_phase_pca_inp.loc[end_index][select_bus]).round(decimals=2)
    if(visualize_fig):
        fig=plt.figure()
        ax=fig.add_subplot(111)
        ax.plot(volt_bad_meas,recons_diff_val,'-',label='Original voltage value'+str(actual_value)+'pu')
        ax.annotate('No error at'+str(actual_value),xy=(actual_value,0),bbox=dict(boxstyle="round", fc="w"))
        plt.xlabel('Faulty Voltage (per unit) value')
        plt.ylabel('Corresponding Residuals in node')
        plt.legend()
        plt.show()
        if(save_fig):
            plt.savefig(os.path.join(figure_path,'Degree of Badness'+ model_name+'.png'),dpi=fig_dpi)
            
#%% Checking the residual sign
estimates_test3_df=pd.DataFrame(data=reconstructed_v3,columns=Feeder1_test3.columns.values)            
input_faulty_meas=Feeder1_test3[buses_bad_data]
estimates_faulty_meas=estimates_test3_df[buses_bad_data]
residuals_faulty_meas=reconstructed_diff3[buses_bad_data]