# DCheM-MILP-Code
To alleviate the greenhouse gas emissions by the chemical industry, electrification has been proposed as a solution where electricity from renewable sources is used to power processes. The adoption of renewable energy is complicated by its spatial and temporal variations.  To address this challenge, we investigate the potential of distributed manufacturing of electrified chemical processes installed in a microgrid. We have proposed a multiscale MILP (Mixed Integer Linear Programming) model for locating modular electrified plants and transmission lines in a microgrid that includes monthly transportation and hourly scheduling decisions. We have also proposed a K-means clustering-based aggregation and disaggregation algorithm to solve the model efficiently. Details of the model and algorithm are given in the paper ... 

The various subdirectories are described below:
1.	src/ Contains the core model code for parameter generation, model generation, and solving the model using algorithm.
2.	Examples/ Contains examples that users can use to test the code and get familiar with its various features. Within this folder, we have one main sets of examples:
  •	Example_1/ , a system consisting of  20 candidate locations in Western Texas where chlor akali plants, solar panels (1500 KW) and wind turbines (100 KW)
3.	docs/ Contains source files for documentation pertaining to the model.

#Requirements

#Running an Instance of code
1.	Download or clone the GenX repository on your machine. For this tutorial it will be assumed to be within your home directory: /home/youruser/DCheM-MILP
Creating the Julia environment and installing dependencies
2.	Start a terminal and navigate into the DCheM-MILP folder.
3.	Type julia --project=. to start an instance of the julia kernel with the project set to the current folder. The . indicates the current folder. On Windows the location of Julia can also be specified as e.g., 'C:\julia-1.6.0\bin\julia.exe --project=.
4.	Store your example in a folder in the Examples Folder in a format similar to that of Example_1
5.	Move to the src folder on DCheM-MILP and run the algo.jl file.  When prompted for the data folder enter the name of the folder required

After solving the aggregated problem, a directory called "Agg_val" is created in src where the variables required from this step in the next step is stored. A folder called deagg is then created where during and after disaggregating each cluster, the log files and required values for  the next step in the form of a csv file are stored.
