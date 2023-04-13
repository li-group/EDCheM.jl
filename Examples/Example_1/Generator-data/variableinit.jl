using JuMP
import GLPK
m = Model(GLPK.Optimizer)
n_loc = 5
n_i = 3
n_ip = 1
n_l = 10+5
n_m = 3
n_tm = 12
n_k = 5
n_s = 24
n_c1 = 6
n_j = 3
function variable_init(m)

#Binary variables
@variable(m,x[1:n_i,1:n_loc],Bin)
@variable(m,n[1:n_l],Bin)
@variable(m,y[1:n_i,1:n_loc,1:n_m,1:n_tm,1:n_k,1:n_s],Bin)
@variable(m,z[1:n_i,1:n_loc,1:n_m,1:n_m,1:n_tm,1:n_k,1:n_s],Bin)
#continous variables
@variable(m,F_1[1:n_c1,1:n_loc,1:n_tm,1:n_k,1:n_s])
@variable(m,F_1_mod[1:n_c1,1:n_loc,1:n_m,1:n_tm,1:n_k,1:n_s])
@variable(m,Q_1[1:n_c1,1:n_loc,1:n_tm])
@variable(m,Tr_1[1:n_c1,1:n_loc,1:n_j,1:n_tm])
@variable(m,Po_1[1:n_loc,1:n_tm,1:n_k,1:n_s])
@variable(m,p_flow[1:n_l,1:n_tm,1:n_k,1:n_s])
@variable(m,p_flowext[1:n_tm,1:n_k,1:n_s])
@variable(m,theta_flow[1:(n_loc+1),1:n_tm,1:n_k,1:n_s])
end
variable_init(m)
