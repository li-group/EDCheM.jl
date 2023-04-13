mkdir("deagg")
finalLoc = []
global planmax = Dict()
for i = 1:n_loc_og
	push!(finalLoc,"r"*string(i))
	planmax["r"*string(i)] = max_pl
end
for i = 1:n_clus
    planmax[(Loc_agg[i])] = yc[i]*max_pl
end
#planmax[("ru")] = n_loc_og

planmax[("ru")] =n_loc_og*max_pl
global xagg = Dict()
Loc1 = Dict()
global trline_toadd = Dict()
for i =1:n_clus
	xagg[Loc_agg[i]] = x_agg[:,Loc_agg[i]]
	Loc1[Loc_agg[i]] = Loc_agg
	trline_toadd[Loc_agg[i]] = []
end
ntagg = Dict()
global ntbun = Dict()
for (i,j) in trline_agg
	if(sum(nt_agg[(i,j),:])>=1)
		ntagg[(i,j)]  = sum(nt_agg[(i,j),:])
		ntbun[(i,j)]  = n_bun_agg[(i,j)]
	end
end
clus_dict = Dict()
clus_no = Dict()
clus_dict_og = Dict()
for i in 1:n_clus
   clus_dict[Loc_agg[i]]  = finalLoc[findall(x->x==i, y1)]
   clus_dict_og[Loc_agg[i]]  = finalLoc[findall(x->x==i, y1)]
   clus_no[Loc_agg[i]] = yc[i]
end
X_arr = Dict()
for i = 1:n_clus
	X_arr[Loc_agg[i]] = Xmod[:,findall(x->x==i, y1)]
end
global Y_val_extra = Dict()
function clus_deagg(c_val,n1)
	n_locout =  n_clus-1+n1
	if(n1==0)
		n_locout = n_clus-1	
		global dist = Dict()
	end
	Loclist = Loc1[c_val]
	Locout = Loclist[(!in).(Loclist,Ref([c_val]))]
	print("Locout is")
	println(Locout)
	println("c_val is")
	println(c_val)
	global trline = []
	
	n_locout = length(Locout)
	if(sum(xagg[c_val])==0)
		return 1
	end
	if(clus_no[c_val]<=2)
		n_loc1 = clus_no[c_val]
		Location = []
		Location_tr = []
		n_loc = n_locout+n_loc1
		for i in clus_dict[c_val]
		  push!(Location_tr,i)
		  push!(Location,i)
		end
		Location = vcat(Location,Locout)
		Location_tr = vcat(Location_tr,Locout)
		push!(Location_tr,"ru")
		print(n_loc1)
		print(n_locout)
		print(n_loc)
		for (i,j) in trline_agg
		if (sum(nt_agg[(i,j),:]) >=1 && i in Location_tr && j in Location_tr)
			push!(trline,Tuple([i,j]))
		end
		end
		P3 = X_arr[c_val]
		for j in Locout
			P3 = hcat(P3,mean(X_arr[j],dims=2))
		end
		#trline = []
		for i = 1:n_loc
		  for j = i+1:n_loc+1
		  		if !(Location_tr[i] in Locout && (Location_tr[j] in Locout || Location_tr[j]=="ru"))
		      	  push!(trline,Tuple([Location_tr[i],Location_tr[j]]))
		      	  push!(trline,Tuple([Location_tr[j],Location_tr[i]]))
		      	 
		      	  if (Location_tr[j]=="ru")
		      	  	ntbun[Tuple([Location_tr[i],Location_tr[j]])] = n_bun_og*planmax[Location_tr[i]]
		      	  	ntbun[Tuple([Location_tr[j],Location_tr[i]])] = n_bun_og*planmax[Location_tr[i]]
		      	  elseif (planmax[Location_tr[i]]==1 || planmax[Location_tr[j]]==1)
		      	  	ntbun[Tuple([Location_tr[i],Location_tr[j]])] = n_bun_og
		      	  	ntbun[Tuple([Location_tr[j],Location_tr[i]])] = n_bun_og
                    else
                  ntbun[Tuple([Location_tr[i],Location_tr[j]])] =  max(planmax[Location_tr[i]],planmax[Location_tr[j]])*n_bun_og
		      	  ntbun[Tuple([Location_tr[j],Location_tr[i]])] = max(planmax[Location_tr[i]],planmax[Location_tr[j]])*n_bun_og
		      	end
		      end
		    end
		end
		if(length(trline_toadd[c_val])>=1)
			for (p,v) in trline_toadd[c_val]
				if(p!=c_val&&v!=c_val)
					push!(trline,(p,v))
				end
			end
		end
        
        for (i,j) in trline_agg
			if(sum(nt_agg[(i,j),:])>=1)
				ntbun[(i,j)]  = n_bun_agg[(i,j)]
			end
		end
		println(ntbun)
        print(size(P3))
        Location_clus = cat(Location,"ru",Consumer_supplier,dims = 1)
		Latitude = cat(P3[n_rep*n_s*n_tm*length(powergen)+1,:],df_loc[n_loc_og+1:end,"Latitude"],dims = 1)
		Longitude = P3[n_rep*n_s*n_tm*length(powergen)+2,:]
		for i = n_loc_og+1:nrow(df_loc)
			Longitude = cat(Longitude,parse(Float64, lstrip(df_loc[i,"Longitude"])),dims = 1)
		end
	
		Loc_clus = DataFrame(Location = Location_clus,Latitude = Latitude, Longitude = Longitude)
		println(Loc_clus)
		dist = cal_dist(Loc_clus)
		P = Dict()
		P = AssignP(P3,P,Location_tr)
	
		Param = gendata(ntbun,trline,Location,dist)
		Param['P'] = P
		trline_new = []
		key = keys(ntagg)
		for k in trline
			if !(k in key)
				push!(trline_new,k)
			end
		end	
		m = modgen(n_loc,Location,Location_tr,trline,Param,planmax,maximum(yc),maximum(values(ntbun)))
		x = m[:x]
		nt = m[:nt]
		y = m[:y_1]
		key = keys(ntagg)
		print(xagg)
		print(xagg[c_val])
		@constraint(m,xcon[c in 1:length(component)],sum(x[component[c],Location[1:n_loc1]])==(xagg[c_val])[component[c]])
		for i in Locout
			@constraint(m,x[:,i].==xagg[i])
		end
			
		for k in key
			if(k in trline)
				c1 = zeros(maximum(yc))		    
		    	for j in 1:trunc(Int, ntagg[k])
		        	c1[j] = 1
		    	end
				@constraint(m,nt[k,:] .== c1)
			end
		end
		for (p,v) in trline
			if !((p,v) in trline_toadd[c_val])
				if (p=="ru"||v=="ru"||(planmax[p]!=1 && planmax[v]!=1))  #Rough estimate of 1 tranmsission line per pair of locations. Can be more but this is just an approximation
					for j in 1+min(planmax[p],planmax[v]):maximum(yc)
						if(j>0)
						@constraint(m,nt[(p,v),j] .== 0)
						end
					end
				else
					for j in max(planmax[p],planmax[v])+1:maximum(yc) #Rough estimate of 1 tranmsission line per pair of locations. Can be more but this is just an approximation
						if(j>0)
						@constraint(m,nt[(p,v),j] .== 0)
						end
					end
				end
			end
		end
		for j in plant
			for i in Loc_agg
				if (i in Locout)
					for mo in modes
						for t= 1:n_tm
							for k = 1:n_k
								for h = 1:n_s
									@constraint(m,y[j,i,mo,t,k,h]==Y_agg[j,i,mo,t,k,h])		
								end
							end
						end
					end
				end
			end
		end
		for j in plant
			for i in Location
				if i in Locout && i in keys(Y_val_extra)
					for mo in modes
						for t= 1:n_tm
							for k = 1:n_k
								for h = 1:n_s
									#@constraint(m,y[j,i,mo,t,k,h]==(Y_val_extra[i])[mo,t,k,h])
										
								end
							end
						end
					end
				end
			end
		end
		set_optimizer_attribute(m,"PreDual",2)
		set_optimizer_attribute(m,"LogFile",joinpath(root,"deagg/ndeaggredmilplogclus"*c_val*".txt"))
		set_optimizer_attribute(m,"Method",2)
		set_optimizer_attribute(m,"Presolve",2)
		set_optimizer_attribute(m,"BarHomogeneous",1)
		#set_optimizer_attribute(m,"Crossover",0)
		set_optimizer_attribute(m, "MIPGap", 0.03)
		#set_optimizer_attribute(m,"Heuristics",0.05)
		#set_optimizer_attribute(m,"MIPFocus",3)
		set_optimizer_attribute(m,"Cuts",0)
		#set_optimizer_attribute(m,"Threads",3)
		optimize!(m)
		global x = value.(m[:x])
		global nt = value.(m[:nt])
		y_1 = value.(m[:y_1])
		for i in Location
			for j in plant
				Y_val_extra[i] = y_1[j,i,:,:,:,:]
			end
		end
		open(joinpath(root,"deagg/ndeaggredmilplogclus"*c_val*".txt"),"a") do io
			println(io,x)
			println(io,nt)
		end
        for i in Location
			if(i in finalLoc)
				c1 = zeros(length(component))
				for j in 1:length(component)
					c1[j] = x[component[j],i]
				end
			   df1 = DataFrame(L1 = i,n = [c1])
			   CSV.write("./deagg/x1.csv", df1, writeheader = false, append = true)
			end
		end
		for (p,v) in trline
			if((p in finalLoc || v in finalLoc) && sum(nt[(p,v),:])>=1)
				if(p in finalLoc && v in vcat(finalLoc,"ru"))
				  df2 = DataFrame(L1 = p,L2 = v,n = floor(Int,round(sum(nt[(p,v),:]))))
				  CSV.write("./deagg/ntdone1.csv", df2, writeheader = false, append = true)
				elseif(p in finalLoc)
					df3 = DataFrame(L1 = p,L2 = v,L3 = [clus_dict_og[v]],n = floor(Int,round(sum(nt[(p,v),:]))))
				  	CSV.write("./deagg/ntmatch1.csv", df3, writeheader = false, append = true)
                end
            end
        end
		return 1
	else
		n1 = n1+1
		X1 = X_arr[c_val]
		X_kmoid =  kmeans(X1[n_rep*n_s*n_tm*length(powergen)+1:n_rep*n_s*n_tm*length(powergen)+2,:], 2,display=:final,tol=10^(-20))
		cv_dict = clus_dict[c_val]
		p1 = assignments(X_kmoid)
		p2 = counts(X_kmoid)
		open(joinpath(root,"deagg/clus"*c_val*".txt"),"a") do io
			println(io,counts(X_kmoid))
			println(io,assignments(X_kmoid))
			println(io,cv_dict[findall(x->x==1,p1)])
			println(io,cv_dict[findall(x->x==2,p1)])
		end
		
	    clus_no[c_val] = 2
	    cv_dict = clus_dict[c_val]
	    clus_dict[c_val] = [c_val*"_"*string(n1)*"_1",c_val*"_"*string(n1)*"_2"]
	    X_arr[c_val] = hcat(mean(X1[:,findall(x->x==1,p1)],dims=2),mean(X1[:,findall(x->x==2,p1)],dims=2))
	    X_arr[c_val*"_"*string(n1)*"_1"] = X1[:,findall(x->x==1,p1)]
	    X_arr[c_val*"_"*string(n1)*"_2"] = X1[:,findall(x->x==2,p1)]
	    planmax[c_val*"_"*string(n1)*"_1"] = p2[1]
	    planmax[c_val*"_"*string(n1)*"_2"] = p2[2]
	   
	    clus_deagg(c_val,n1)
	    print(x[:,c_val*"_"*string(n1)*"_1"])
	    xagg[c_val*"_"*string(n1)*"_1"] = x[:,c_val*"_"*string(n1)*"_1"]
	    xagg[c_val*"_"*string(n1)*"_2"] = x[:,c_val*"_"*string(n1)*"_2"]
	    k = keys(ntagg)
	    trline_toadd[c_val*"_"*string(n1)*"_1"] = []
	    trline_toadd[c_val*"_"*string(n1)*"_2"] = []
	    for (p,v) in trline
	    	
	        if(floor(Int,round(sum(nt[(p,v),:])))>=1 && !((p,v) in k))
	    	    ntagg[(p,v)] = floor(Int,round(sum(nt[(p,v),:])))
	    	    if(p!=c_val*"_"*string(n1)*"_1" && v!=c_val*"_"*string(n1)*"_1")
	    	    	push!(trline_toadd[c_val*"_"*string(n1)*"_1"],(p,v))
	    	    end
	    	    if(p!=c_val*"_"*string(n1)*"_2" && v!=c_val*"_"*string(n1)*"_2")
	    	    	push!(trline_toadd[c_val*"_"*string(n1)*"_2"],(p,v))
	    	    end
	    	end
        end
        print(trline_toadd)
	    ntagg[(c_val*"_"*string(n1)*"_1","ru")] = floor(Int,round(sum(nt[(c_val*"_"*string(n1)*"_1","ru"),:])))

        ntagg[(c_val*"_"*string(n1)*"_2","ru")] = floor(Int,round(sum(nt[(c_val*"_"*string(n1)*"_2","ru"),:])))
        
        print(cv_dict)
        println(findall(x->x==2,p1))
        println(cv_dict[findall(x->x==1,p1)])
        clus_dict[c_val*"_"*string(n1)*"_1"] = cv_dict[findall(x->x==1,p1)]
        clus_dict[c_val*"_"*string(n1)*"_2"] = cv_dict[findall(x->x==2,p1)]
        clus_dict_og[c_val*"_"*string(n1)*"_1"] = cv_dict[findall(x->x==1,p1)]
        clus_dict_og[c_val*"_"*string(n1)*"_2"] = cv_dict[findall(x->x==2,p1)]
        print(clus_dict_og)
        println("check")
        println(clus_dict[c_val*"_"*string(n1)*"_1"])
        clus_no[c_val*"_"*string(n1)*"_1"] = p2[1]
        clus_no[c_val*"_"*string(n1)*"_2"] = p2[2]
        println("Loclist check")
        Loc1[c_val*"_"*string(n1)*"_1"] = vcat((Loc1[c_val])[(!in).((Loc1[c_val]),Ref([c_val]))],c_val*"_"*string(n1)*"_1",c_val*"_"*string(n1)*"_2")
        Loc1[c_val*"_"*string(n1)*"_2"] = vcat((Loc1[c_val])[(!in).((Loc1[c_val]),Ref([c_val]))],c_val*"_"*string(n1)*"_1",c_val*"_"*string(n1)*"_2")
        print(Loc1[c_val*"_"*string(n1)*"_1"])
        print(Loc1[c_val*"_"*string(n1)*"_2"])
        clus_deagg(c_val*"_"*string(n1)*"_1",n1)        
        clus_deagg(c_val*"_"*string(n1)*"_2",n1)
    end
    return 1 
end