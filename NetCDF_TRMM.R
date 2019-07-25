#Basically use the metadata of the netcdf to figure out how the data is arranged 
#The ordering of the lon/lat etc can be understood using the ncvar_get output
#For variables containing multiple dimension like time/depth etc get a sense using the dim of the ncvar_get output for that varible
#Then when you actually extract variable of interest (e.g soil moisture, gravity), use the dimensions of the output array to get a sense
#Remember arrays can be of a higher order (more than 2 dim) unlike matrix/dataframes
#The adply function (slow but works like magic) currently splits up data by rows then columns such that the first 2 columns of the output
#are basically the Lon/Lat (depends on how the variable array is stored, the dim of the variable array is key to get this understanding)

#Input File Directory
setwd("/nfs/HealthandResourcePolicy-data/Task 2/TRMM_Precipitation/TRMM_data")

require(ncdf4)
require(raster)
require(dplyr)
require(plyr)

myfiles <- list.files(pattern = "nc4",  full.names = TRUE)
i=1
mydata=nc_open(myfiles[i])
lon=ncvar_get(mydata,"lon")
nlon=dim(lon)
lat=ncvar_get(mydata,"lat")
nlat=dim(lat)
precip=ncvar_get(mydata,"precipitation")
nprecip=dim(precip)

#Basically use the 
var1_melt <- adply(precip,c(1,2))
var1 = var1_melt

cur_date = substr(myfiles[i],14,21)
lonlat <- expand.grid(lat, lon)
temp_all_data <- data.frame(cbind(lonlat, var1$V1))
all_data = temp_all_data
colnames(all_data)[3]=cur_date
nc_close(mydata)
i=2

for (i in 2:length(myfiles)){
  
  cur_file=myfiles[i]
  mydata=nc_open(cur_file)
  #Basically use the 
  precip=ncvar_get(mydata,"precipitation")
  nprecip=dim(precip)
  
  #Basically use the 
  var1_melt <- adply(precip,c(1,2))
  var1 = var1_melt

  cur_date = substr(myfiles[i],14,21)
  all_data[i+2] <- var1$V1
  colnames(all_data)[i+2]= cur_date
  nc_close(mydata)
  print(i)
}

#write.csv(all_data,'temp_SM_lay2.csv')
write.csv(all_data,'All_data_precip_TRMM_190725.csv')
#saveRDS(all_data,"All_data_precip_TRMM_190725.rds")
