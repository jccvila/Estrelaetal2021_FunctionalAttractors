# Estrelaetal2021

FBA simulations that were used for Estrela et al 2021. 

Manuscript entitled Functional attractors in microbial community assembly

Python Version 3.7
R version 4.0.3
Standard Python packages : Numpy, Pandas, Matplotlib, SciPy, Seaborn, pickle, scipy
Standard R packages: ggplot2, data.table, ggpubr,gdata,gridExtra,Metrics,operators, Curl
Cobrapy Version 0.17.1

# Input Data Source

Model_list.txt: can be obtained from http://bigg.ucsd.edu/api/v2/models/ #True as of March 9th 2020  2pm. Used to download all Biggs models.
Pputida_models.csv is the first excel sheet (titled PID)  of Table S5 in nogales et al 2019 https://doi.org/10.1111/1462-2920.14843. Used to generate P.putida models
SBML versions of Published psuedomonas models not in biggs database were downloaded from original publication were possible. Note that for iMO1056 and iSB1139 an sbml is not included in the original publication. 
Stored in Data/Published_Pseud_Models folder
    a) iPAE1146.xml https://bme.virginia.edu/csbl/Downloads1-pseudomonas.html
    b) iPAU1129.xml https://bme.virginia.edu/csbl/Downloads1-pseudomonas.html
    c) iPB890.xml https://pubs.rsc.org/en/content/articlelanding/2015/MB/C5MB00086F#!divAbstract 
    d) iMO1056.xml https://github.com/opencobra/m_model_collection
    e) iSB1139_COBRA.xml was obtained through personal correspondance with lead author Sven Borgas
Models built from whole genomes stored in Data/Whole_Genome_Models built using KBASE . See manuscript for detailed protocol and KBASE narrative in Data/Whole_Genome_Models to reproduce analysis. Genomes are stored in Data/Isolates and

# Reproducing Analysis

Step 1 is to run download_models.R to download all biggs models -generates biggs_model list
Step 2 is to run Gapfilling.py which will create the strain specific models of pseudomonas (as well as the irreversible version) using the iJN1463.xml model as a template
Step 3 is to run jupyter notebook Alternative_state. - This will take a while. Raw data is stored in Data/Raw/
Step 4 Copy relevants outputs of jupyter notebook into Data/Raw/Sensitivity_Analysis.csv 
Step 5 Run Figures.R to generate plots and generate processed data files corresponding direclty to the data in the figures.



