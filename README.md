# EDCheM.jl

This package implements an MILP model and aggregation-disaggregation algorithm for solving a multi-scale facility location problem of electrified chemical processes. The details of the algorithm can be found in [our paper](https://aiche.onlinelibrary.wiley.com/doi/10.1002/aic.18265).

If you find this work useful, please cite our paper as 
 ```
  @article{https://doi.org/10.1002/aic.18265,
author = {Ramanujam, Asha and Constante-Flores, Gonzalo E. and Li, Can},
title = {Distributed manufacturing for electrified chemical processes in a microgrid},
journal = {AIChE Journal},
volume = {n/a},
number = {n/a},
pages = {e18265},
keywords = {distributed manufacturing, electrification, mathematical optimization, multiscale integration},
doi = {https://doi.org/10.1002/aic.18265},
url = {https://aiche.onlinelibrary.wiley.com/doi/abs/10.1002/aic.18265},
eprint = {https://aiche.onlinelibrary.wiley.com/doi/pdf/10.1002/aic.18265}
}
  ```
## Table of Contents
1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Subdirectories](#subdirectories)
4. [Running an instance of code](#running)
5. [Citation](#citation)
## [Overview](#overview)
To alleviate the greenhouse gas emissions by the chemical industry, electrification has been proposed as a solution where electricity from renewable sources is used to power processes. The adoption of renewable energy is complicated by its spatial and temporal variations. To address this challenge, we investigate the potential of distributed manufacturing for electrified chemical processes installed in a microgrid. We propose a multiscale mixed-integer linear programming model for locating modular electrified plants, renewable-based generating units, and power lines in a microgrid that includes monthly transportation and hourly scheduling decisions. We propose a K-means clustering-based aggregation disaggregation matheuristic to solve the model efficiently. We provide the model and the algorithm here.

## [Requirements](#requirements)
Run the following code on the directory to install the julia packages
  ```
  julia Install.jl
  ```
  In addition, follow the instructions on [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl) to install the solver Gurobi.
## [Subdirectories](#subdirectories)
The various subdirectories are described below:
1.	src/ Contains the core model code for parameter generation, model generation, and solving the model using algorithm.
2.	Examples/ Contains examples that users can use to test the code and get familiar with its various features. Within this folder, we have one main sets of examples:
  •	Example_1/ , a system consisting of  20 candidate locations in Western Texas where chlor akali plants, solar panels (1500 KW) and wind turbines (100 KW)

## [Running an instance of code](#running)
1.	Store your example in a folder in the Examples Folder in a format similar to that of Example_1
2.	Move to the src folder on EDCheM.jl and run the algo.jl file. The following is the way:
  ```
  cd ./src
  julia algo.jl
  ```
3. When prompted for the data folder enter the name of the folder required

After solving the aggregated problem, a directory called "Agg_val" is created in src where the variables required from this step in the next step is stored. A folder called deagg is then created where during and after disaggregating each cluster, the log files and required values for  the next step in the form of a csv file are stored.

## [Citation](#citation)
Cite us 
 ```
  @article{https://doi.org/10.1002/aic.18265,
author = {Ramanujam, Asha and Constante-Flores, Gonzalo E. and Li, Can},
title = {Distributed manufacturing for electrified chemical processes in a microgrid},
journal = {AIChE Journal},
volume = {n/a},
number = {n/a},
pages = {e18265},
keywords = {distributed manufacturing, electrification, mathematical optimization, multiscale integration},
doi = {https://doi.org/10.1002/aic.18265},
url = {https://aiche.onlinelibrary.wiley.com/doi/abs/10.1002/aic.18265},
eprint = {https://aiche.onlinelibrary.wiley.com/doi/pdf/10.1002/aic.18265}
}
  ```
