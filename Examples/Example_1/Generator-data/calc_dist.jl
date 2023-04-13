#cd("C://Users//aramanuj//OneDrive - purdue.edu//Documents//GitHub//Asha_qualifier//Generator-data 2")
#df_loc = DataFrame(CSV.File(joinpath(root,"Generator-data 2","location.csv")))

#df_loc = DataFrame(CSV.File(joinpath(root,"Location20.csv")))
#df_loc = df_loc[:,["Location 1","Location 2","Distance in km"]]
function cal_dist(df_loc)
	dist = Dict()
	for i = 1:nrow(df_loc)
		for j = i+1:nrow(df_loc)
			lon1 = df_loc[i,"Longitude"]
			lon2 = Float64, df_loc[j,"Longitude"]
			lat1 = df_loc[i,"Latitude"]
			lat2 = df_loc[j,"Latitude"]
			lon1 = deg2rad(lon1)
			lon2 = deg2rad(lon2)
			lat1 = deg2rad(lat1)
			lat2 = deg2rad(lat2)
			dlon = lon2 - lon1
			dlat = lat2 - lat1
			a = (sin(dlat / 2))^2 + cos(lat1) * cos(lat2) * (sin(dlon / 2))^2

			cs = 2 * asin(sqrt(a))

			# Radius of earth in kilometers. Use 3956 for miles
			r = 6371
			dist[(df_loc[i,"Location"],df_loc[j,"Location"])] = cs * r
		end
	end
	return dist
end
