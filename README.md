# EDCheM.jl
This package implement an MILP model and aggregation-disaggregation algorithm for solving a multi-scale facility location problem of electrified chemical processes. The details of the algorithm can be found in the [preprint]()

The various subdirectories are described below:
1.	src/ Contains the core model code for parameter generation, model generation, and solving the model using algorithm.
2.	Examples/ Contains examples that users can use to test the code and get familiar with its various features. Within this folder, we have one main sets of examples:
  •	Example_1/ , a system consisting of  20 candidate locations in Western Texas where chlor akali plants, solar panels (1500 KW) and wind turbines (100 KW)


## Requirements
Run the following code on the directory to install the julia packages
  ```
  julia Install.jl
  ```
  In addition, follow the instructions on [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl) to install the solver Gurobi.
## Running an Instance of code
1.	Store your example in a folder in the Examples Folder in a format similar to that of Example_1
2.	Move to the src folder on EDCheM.jl and run the algo.jl file. The following is the way:
  ```
  cd ./src
  julia algo.jl
  ```
3. When prompted for the data folder enter the name of the folder required

After solving the aggregated problem, a directory called "Agg_val" is created in src where the variables required from this step in the next step is stored. A folder called deagg is then created where during and after disaggregating each cluster, the log files and required values for  the next step in the form of a csv file are stored.
