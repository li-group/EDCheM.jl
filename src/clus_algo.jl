mkdir("Agg_val")
function clus_agg(Xmod,n_clus)
	print(size(Xmod))
	X_size = size(Xmod)
	Xloc = Xmod[X_size[1]-1:X_size[1],:]
	global ob_min = 0
	
	for i = 1:10
		X_km =  kmeans(Xloc, n_clus,display=:final,tol=10^(-20))
		if(i==1)
	        global y1 = assignments(X_km)
		    global yc = counts(X_km)
		    global ob_min = X_km.totalcost
		else
			if(X_km.totalcost<ob_min)
				global y1 = assignments(X_km)
		   		global yc = counts(X_km)
		        global ob_min = X_km.totalcost
		    end
		end
    end	


	root = pwd()
	open(joinpath(root,"./Agg_val/agg_clus_no.txt"),"a") do io
	  println(io,y1)
	  println(io,yc)
	end
	println(y1)
	println(yc)
	P3 = mean(Xmod[:,findall(x->x==1, y1)],dims=2)
	for i = 2:n_clus
		println(size(P3))
		P3 = hcat(P3,mean(Xmod[:,findall(x->x==i, y1)],dims=2))
	end
	println(size(P3))
	Location = []
	Location_tr = []
	
    n_loc = n_clus
	for i in 1:n_loc
	  push!(Location_tr,"R"*string(i))
	  push!(Location,"R"*string(i))
	end
	push!(Location_tr,"ru")	
	Location_agg = cat(Location,"ru",Consumer_supplier,dims = 1)
	Latitude = cat(P3[X_size[1]-1,:],df_loc[n_loc_og+1:end,"Latitude"],dims = 1)
	Longitude = P3[X_size[1],:]
	for i = n_loc_og+1:nrow(df_loc)
		Longitude = cat(Longitude,parse(Float64, strip(df_loc[i,"Longitude"])),dims = 1)
	end
	Loc_agg = DataFrame(Location = Location_agg,Latitude = Latitude, Longitude = Longitude)
	println(Loc_agg)
	dist = cal_dist(Loc_agg)
	trline = []
	for i = 1:n_loc+1
	  for j = 1:n_loc+1
	    if(i!=j)
	      push!(trline,Tuple([Location_tr[i],Location_tr[j]]))
	    end
	  end
	end

	plan_max = Dict()
	for i = 1:n_loc
    	plan_max[(Location[i])] = yc[i]*max_pl #Maximum number of plants in a location
	end
	plan_max[("ru")] = max_pl
	P = Dict()
	n_bun_agg = Dict()
	P = AssignP(P3,P,Location_tr)
	n_bun = Dict()
	for (i,j) in trline
		n_bun_agg[(i,j)] = max(plan_max[i],plan_max[j])*n_bun_og #Bundle the plants
    	n_bun[(i,j)] = n_bun_agg[(i,j)]
	end
  
	Param = gendata(n_bun,trline,Location,dist)
	plan_max[("ru")] = 100*max_pl
	Param['P'] = P
    m = modgen(n_loc,Location,Location_tr,trline,Param,plan_max,maximum(yc),maximum(values(n_bun_agg)))
    nt = m[:nt]
       for (p,v) in trline
		for j in 1+min(plan_max[p],plan_max[v]):maximum(yc) #Rough estimate of 1 tranmsission line per pair of locations. Can be more but this is just an approximation
			if(j>0)
			    @constraint(m,nt[(p,v),j] .== 0)
			end
		end
	end
	x = m[:x]   
	set_optimizer_attribute(m,"PreDual",2)
    set_optimizer_attribute(m,"LogFile",joinpath(root,"./Agg_val/2log_agg"*".txt"))
    set_optimizer_attribute(m,"Method",2)
	#set_optimizer_attribute(m,"DegenMoves",0)
    set_optimizer_attribute(m,"BarHomogeneous",1)
	set_optimizer_attribute(m, "MIPGap", 0.01)
	#undo = relax_integrality(m)
	optimize!(m)
	x = value.(m[:x])
	nt = value.(m[:nt])
	Y = value.(m[:y_1])
	open(joinpath(root,"./2agg_clusval"*".txt"),"a") do io
		println(io,x)
		println(io,nt)
	end
    return x,nt,Location,trline,yc,y1,Y,n_bun_agg
	
end

x_agg,nt_agg,Loc_agg,trline_agg,yc,y1,Y_agg,n_bun_agg = clus_agg(Xmod,n_clus)
FileIO.save("./Agg_val/x_agg1.jld2","x",x_agg)
FileIO.save("./Agg_val/nt_agg1.jld2","nt",nt_agg)
FileIO.save("./Agg_val/Loc_agg1.jld2","Loc",Loc_agg)
FileIO.save("./Agg_val/trline_agg1.jld2","trline",trline_agg)
FileIO.save("./Agg_val/yc_agg1.jld2","yc",yc)
FileIO.save("./Agg_val/y1_agg1.jld2","y1",y1)
FileIO.save("./Agg_val/Y_agg1.jld2","Y",Y_agg)
FileIO.save("./Agg_val/n_bun_agg1.jld2","n_bun",n_bun_agg)
