root = pwd()
df_x = DataFrame(CSV.File(joinpath(root,"deagg/x1.csv"),header=false))
#print(df_x)
x_val = Dict()
for i = 1:nrow(df_x)
  a = chop(df_x[i,2],head = 1,tail=1)
  b = split(a, ",")
  c = []
  for j in 1:3
    push!(c,trunc(Int,parse(Float64,b[j])))
  end
  #print(df_x[i,1])
  x_val[String.(df_x[i,1])] = c
end
Location = []
Location_tr = []
for i in 1:n_loc_og
  push!(Location_tr,String.("r"*string(i)))
  push!(Location,String.("r"*string(i)))
end
push!(Location_tr,"ru")
for i in Location
  if !(i in keys(x_val))
    x_val[i] = [0,0,0]
  end
end
locno = []
nlocno = Dict()
for i in Location
  if (sum(x_val[i])==0)
    push!(locno,i)
  end
end
if(isfile((joinpath(root,"deagg/ntdone1.csv")))==true)
  df_nt1 = DataFrame(CSV.File(joinpath(root,"deagg/ntdone1.csv"),header=false))
else
  df_nt1 = DataFrame()
end

trline = []
nt_aggdone = Dict()
nt_aggmatch = Dict()
for i = 1:nrow(df_nt1)
  if !((String.(df_nt1[i,1]),String.(df_nt1[i,2])) in trline)
    push!(trline,(String.(df_nt1[i,1]),String.(df_nt1[i,2])))
    nt_aggdone[(String.(df_nt1[i,1]),String.(df_nt1[i,2]))] = df_nt1[i,3]
    if(String.(df_nt1[i,1]) !="ru" && String.(df_nt1[i,2]) !="ru" )
        nt_aggmatch[[(String.(df_nt1[i,1]),String.(df_nt1[i,2]))]] = df_nt1[i,3]
      end
  end
end

if(isfile((joinpath(root,"deagg/ntmatch1.csv")))==true)
  df_nt2 = DataFrame(CSV.File(joinpath(root,"deagg/ntmatch1.csv"),header=false))
else
  df_nt2 = DataFrame()
end
tagg = []
for i = 1:nrow(df_nt2)
  a = df_nt2[i,3]
  a = strip(a,['A','n','y','[',']'])
  b = split(a, ",")
  d = String.(df_nt2[i,2])
  for j in 1:length(b)
    c = b[j]
    for k in 1:length(c)
      if(c[k]=='r')
        c1 = 0
        for m in 1:length(c)
          if(isdigit(c[m+k]))
            c1 = c1+1
          else
            break
          end
        end
      b[j] = SubString(c,k,k+c1)
      end
    end
  end
  t1 = []
  t2 = []
  for j in 1:length(b)
      push!(tagg,(String.(df_nt2[i,1]),b[j]))
      push!(t1,(String.(df_nt2[i,1]),b[j]))
      push!(t2,b[j])
  end
  println(d)
  println(String.(df_nt2[i,1]))
  f = 0
  for j in t2
    f = f+sum(x_val[j])
  end
  if(sum(x_val[String.(df_nt2[i,1])])>0 && f>0)
    nt_aggmatch[t1] = df_nt2[i,4]
  end
end
println(nt_aggmatch)
tagg = []
nt_aggmatch1 = Dict()
for i in keys(nt_aggmatch)
    q1 = nt_aggmatch[i]
    s1 = i
    for j in 1:length(s1)
        p = (s1[j])[1]
        v = (s1[j])[2]
        if (parse(Int64,chop(p,head=1,tail=0))>parse(Int64,chop(v,head=1,tail=0)))
            s1[j] = (v,p)
        end
        if !((s1[j]) in tagg)
            push!(tagg,s1[j])
        end

    end
nt_aggmatch1[s1] = q1
end


println("tagg")
println(tagg)
println("nt_aggmatch1")
println(nt_aggmatch1)
using JuMP
import Gurobi
model = Model(Gurobi.Optimizer)

@variable(model,0<=nagg[(i,j) in tagg]<=8,Int)
@variable(model,p[(i,j) in tagg],Bin)
@variable(model,q[i in locno],Bin)
for i in keys(nt_aggmatch1)
      @constraint(model,sum(nagg[i])>=nt_aggmatch1[i])
end
for (i,j) in tagg
  if (j,i) in tagg
    println("Problem")
    #@constraint(model,nagg[(i,j)]==nagg[(j,i)])
  end
end

for i in locno
  t1 = []
  for j in tagg
    q1 = j[1]
    q2 = j[2]
    if(i in j && !(j in t1) && !((q2,q1) in t1))
      push!(t1,j)
    end
  end
  nlocno[i] = t1
end
open(joinpath(root,"./checktropt.txt"),"a") do io
            println(io,nlocno)
            println(io,"Check no")
end
for i in keys(nt_aggmatch1)
  for j in keys(nt_aggmatch1)
    if(i!=j)
      for p in i
        q1 = p[1]
        q2 = p[2]
        if (p in j || (q2,q1) in j)
           @constraint(model,nagg[p]>=1)
           open(joinpath(root,"./checktropt.txt"),"a") do io
            println(io,i)
            println(io,j)
            println(io,p)
           end
        end
      end
    end
  end
end
for(i,j) in tagg
  @constraint(model,nagg[(i,j)]<=8*p[(i,j)])
   @constraint(model,nagg[(i,j)]>=p[(i,j)])
end
for i in locno
  j = nlocno[i]
  if(length(j)>=1)
    @constraint(model,sum(p[j])<=0.95+22*q[i])
    @constraint(model,sum(p[j])>=1.05-22*(1-q[i]))
  end
end

dist = cal_dist(df_loc)
@objective(model,Min,sum(dist[i]*nagg[i] for i in tagg))
optimize!(model)
n_aggval = value.(model[:nagg])
println(value.(model[:p]))
println(value.(model[:q]))
for i in tagg
    if(n_aggval[i]>0)
        push!(trline,i)
        nt_aggdone[i] =  n_aggval[i]
    end
end
for i in keys(nt_aggdone)
    nt_aggdone[i] = trunc(Int,nt_aggdone[i])
end



for i in locno
  t1 = []
  for j in trline
    if(i in j)
      push!(t1,j)
    end
  end
  if(length(t1)==1)
    deleteat!(trline, findall(x->x==t1[1],trline))
  end
  #nlocno[i] = t1
end

for (i,j) in trline
  if !((j,i) in trline)
    push!(trline,(j,i))
    nt_aggdone[(j,i)] = nt_aggdone[(i,j)]
  end
end
for (i,j) in trline
  nt_aggdone[(j,i)] = max(nt_aggdone[(j,i)],nt_aggdone[(i,j)])
  nt_aggdone[(i,j)] = nt_aggdone[(j,i)]
end
t_del = []
for (i,j) in trline
  if nt_aggdone[(i,j)] == 0 
    push!(t_del,trline)
  end
end
for (i,j) in t_del
   deleteat!(trline, findall(x->x==(i,j),trline))
end

println(trline)
trline1 = trline
for i in Location
  a = 0
  if(sum(x_val[i])>0)
    for j in trline1
      if(i in j)
        a = 1
      end
    end
    if(a==0)
      push!(trline,(i,"ru"))
      push!(trline,("ru",i))
      nt_aggdone[(i,"ru")] = 1
      nt_aggdone[("ru",i)] = 1
    end
  end
end
plan_max = Dict()

trline = union(trline)


for i in Location
  plan_max[(i)] = max_pl
end 
n_lij_og = maximum(yc)
#n_bun_og = 8
ntbun = Dict()
for (i,j) in trline
  ntbun[(i,j)] = n_bun_og
end
Param = gendata(ntbun,trline,Location,dist)
Param['P'] = P_og
m = modgen(n_loc_og,Location,Location_tr,trline,Param,plan_max,n_lij_og,n_bun_og)
x = m[:x]
nt = m[:nt]

for i in keys(x_val)
    @constraint(m,x[:,i] .== x_val[i] )
end
for i in trline
    c1 = zeros(n_lij_og)
    for j in 1:nt_aggdone[i]
        c1[j] = 1
    end
    @constraint(m,nt[i,:].==c1)
end

println(x_val)
println(nt_aggdone)
y_1 = m[:y_1]
z_1 = m[:z_1]
for i in plant
for loc in Location
  for mo in modes
    for t= 1:n_tm
      for k = 1:n_k
        for h = 1:n_s
          set_integer(y_1[i,loc,mo,t,k,h])
          for mo1 in modes
            set_integer(z_1[i,loc,mo,mo1,t,k,h])
          end
        end
      end
    end
  end
end
end
set_optimizer_attribute(m,"PreDual",2)
set_optimizer_attribute(m,"LogFile",joinpath(root,"./20_loc_check_mipfin.txt"))
set_optimizer_attribute(m,"Method",2)
set_optimizer_attribute(m,"DegenMoves",0)
#set_optimizer_attribute(m,"Crossover",0)
set_optimizer_attribute(m, "MIPGap", 0.005)

optimize!(m)

x = value.(m[:x])
nt = value.(m[:nt])
FileIO.save("x1.jld2","x",x)
FileIO.save("nt1.jld2","nt",nt)
open(joinpath(root,"./20_loc_check_mipfin.txt"),"a") do io
println(io,x)
println(io,nt)
println(io,trline)
end

x = value.(m[:x])
y= value.(m[:y_1])
z = value.(m[:z_1])
F_1_mod = value.(m[:F_1_mod])
F_1 = value.(m[:F_1])
Q_1 = value.(m[:Q_1])
Tr_1 = value.(m[:Tr_1])
sltr_1 = value.(m[:sltr_1])
Po_1 = value.(m[:Po_1])
nt = value.(m[:nt])
p_flow = value.(m[:p_flow])
p_cu = value.(m[:p_cu])
p_flowext = value.(m[:p_flowext])
V_flow = value.(m[:V_flow])


using Serialization
mkdir("Variables")
serialize("Variables/x.jls",x)
serialize("Variables/y.jls",y)
serialize("Variables/z.jls",z)
serialize("Variables/F_1_mod.jls",F_1_mod)
serialize("Variables/F_1.jls",F_1)
serialize("Variables/Q_1.jls",Q_1)
serialize("Variables/Tr_1.jls",Tr_1)
serialize("Variables/sltr_1.jls",sltr_1)
serialize("Variables/Po_1.jls",Po_1)
serialize("Variables/nt.jls",nt)
serialize("Variables/p_flow.jls",p_flow)
serialize("Variables/p_cu.jls",p_cu)
serialize("Variables/p_flowext.jls",p_flowext)
serialize("Variables/V_flow.jls",V_flow)
serialize("Variables/Location.jls",Location)
serialize("Variables/trline.jls",trline)

#x = FileIO.load("Variables/x.jld2","x")
x = deserialize("Variables/x.jls")
h2 = Base.@locals
Param_all = Dict()    
for i in keys(h2)
  Param_all[String(i)] = h2[i]
end

open(joinpath(root,"result_file.txt"),"a") do io
    println(io,solution_summary(m))

    println(io,"x=")
    println(io,x)
    println(io,"nt=")
    println(io,nt)
    println(io,"Total material cost =")
    println(io,sum(value.(matcostc)))
    println(io,"only material cost =")
    #println(io,sum(value.(matcostnormc)))

    println(io,"Transportation cost =")
    println(io,sum(value.(transcostc)))

    println(io,"Electricity cost =")
    println(io,sum(value.(eleccost)))

    println(io,"FIXOP cost =")
    println(io,sum(value.(FIXOP)))

    println(io,"FIXOP_l cost =")
    println(io,sum(value.(FIXOP_l)))

    println(io,"CAPEX cost =")
    println(io,sum(value.(CAPEX)))

    println(io,"CAPEX_l =")
    println(io,sum(value.(CAPEX_l)))
end
