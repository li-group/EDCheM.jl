using DataFrames
using CSV
using Statistics
using Clustering
using FileIO
using DualDecomposition
using DataFrames
using CSV
using Statistics
using Clustering
using FileIO
using JuMP, Ipopt
using Random
using MPI
using JuMP
import Gurobi
using Dates
root = pwd()
print("Enter name of the data folder \n\n") 
  
# Calling rdeadline() function
name = readline()

Example_folder = name
println("Starting Implementation")
cd("../")
rootn = pwd()
cd(root)
include(joinpath(rootn,"Examples",Example_folder,"Preprocess_input.jl"))
include(joinpath(root,"calc_dist.jl"))
include(joinpath(root,"datagen_1.jl"))
include(joinpath(root,"model_mod.jl"))

open(joinpath(root,"./timecheck.txt"),"a") do io
	println(io,"Start")
	println(io,Dates.format(now(), "HH:MM")  )
end
cd(root)
include(joinpath(root,"clus_algo.jl"))
open(joinpath(root,"./timecheck.txt"),"a") do io
	println(io,"Clustering")
	println(io,Dates.format(now(), "HH:MM")  )
end

x_agg = FileIO.load("./Agg_val/x_agg1.jld2","x")
nt_agg = FileIO.load("./Agg_val/nt_agg1.jld2","nt")
Loc_agg = FileIO.load("./Agg_val/Loc_agg1.jld2","Loc")
trline_agg = FileIO.load("./Agg_val/trline_agg1.jld2","trline")
yc = FileIO.load("./Agg_val/yc_agg1.jld2","yc")
y1 = FileIO.load("./Agg_val/y1_agg1.jld2","y1")
Y_agg = FileIO.load("./Agg_val/Y_agg1.jld2","Y")
n_bun_agg = FileIO.load("./Agg_val/n_bun_agg1.jld2","n_bun")
include(joinpath(root,"declus_algo.jl"))


for i in Loc_agg
	clus_deagg(i,0)
end

open(joinpath(root,"./timecheck.txt"),"a") do io
	println(io,"Declustering")
	println(io,Dates.format(now(), "HH:MM")  )
end
include(joinpath(root,"check_algo1.jl"))

open(joinpath(root,"./timecheck.txt"),"a") do io
	println(io,"Check")
	println(io,Dates.format(now(), "HH:MM")  )
end

