# Master thesis Chap3 programs

**Master thesis** "Anomaly Detection in Distribution system measurements using machine learning" [Online link]
(http://www.dissertations.wsu.edu/Hold/A_Imayakumar_011592767.pdf)

**Advisors:** *Dr. Anjan Bose and Dr. Anamika Dubey*

PCA data generation (MATLAB)

Ensure that file directory is correct for all simulations and Data generation base files to be in path in MATLAB. Annual Loadshapes: pecan street dataset (35 different), which is not available for public use. 
> Kindly refer to Chap. 4, ref [4] on how to access this dataset.

- Loadname_generate.m: Performs the snapshot power flow and generates a text file assigning loadshapes. Save the load names to mat file to avoid re-running the simulation for different profile assignment.
- PCA_data_extract_diff_test_systems.m: 
  - Main program which extracts all possible measurements in Bus, PCElement, PDElement for different elements in openDSS
  - Maximum expected simulation time is 280 s for IEEE 8500 node system
- PCA_excel_file_out.m: Writes the voltages by phase in output excel file, which is to be run immediately after the PCA_data_extract...m file 

**IMP:** Since the voltages are in per unit and primary nodes change for each system, manually check if the voltages are primary node voltages. To do this, open Bus.V variable and check for the column where the voltage level changes, which will show the end node. For example, Column 232 in Bus.V is 120 V range, while voltages till 232 are in 2402 V. Thus, only the first 231 nodes are primary voltages
File used in research [Folder: PCAdatasets]

Batch PCA (python)
- Network_Anomaly_detection_PCA.py:
  - Read input file from “PCA_excel_file_out.m” for Batch PCA
  - Perform full subspace projection to check the voltage correlation. Typically, the number of components is less than 4.
  - If you have single output voltage file, which is the case except for event validation scenarios, split the data into 70 and 30 % for train and testing
  - For event validation, read a new excel file for testing scenario.
  - Anomaly introduced for 3-time steps with line and heat map visualizations
    * Single Missing measurement
    * Single bad measurement
    * Multiple bad measurements in 3 buses
  - Final optional section of checking for different level of badness of single input data 
