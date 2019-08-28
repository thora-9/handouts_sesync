library(airGR)
library(zoo)
library(lubridate)
library(hydroTSM)


#Load temperature data
temp = readRDS("InputPT_test_1975_2016.rds")
jd_temp = yday(index(temp))
core_temp = as.numeric(coredata(temp$mtz))

PE_temp = PE_Oudin(jd_temp,core_temp,Lat = 13,LatUnit = "deg")

PE_zoo = zoo(PE_temp,index(temp))


#Load TRMM Precip data
trmm_precip = read.csv("TRMM_UpperSR.csv")

n = ncol(trmm_precip)
med_ppt = apply(trmm_precip[,4:n],2,max)

dates1 = colnames(trmm_precip[4:n])
dates2 = substr(dates1,2,9)
dates3 = as.POSIXct(dates2,tz = "",'%Y%m%d')
dates4 = as.Date(dates3)

trmm_zoo = zoo(med_ppt,dates4)

ppt_temp = merge.zoo(trmm_zoo,PE_zoo,all = FALSE)

ppt_temp2 = izoo2rzoo(ppt_temp)

ppt_temp2$trmm_zoo[is.na(ppt_temp2$trmm_zoo)] = 0
ppt_temp2$PE_zoo[is.na(ppt_temp2$PE_zoo)] = mean(temp,na.rm=TRUE)



#This only works if the GR4J script has been run

mdate = as.POSIXct(index(ppt_temp2))
mppt = as.numeric(coredata(ppt_temp2$trmm_zoo))
mtemp = as.numeric(coredata(ppt_temp2$PE_zoo))

InputsModel <- CreateInputsModel(FUN_MOD = RunModel_GR4J, DatesR = mdate,
                                 Precip = mppt, PotEvap = mtemp)


str(InputsModel)

n2 = length(ppt_temp2$trmm_zoo)
Ind_Run <- seq(366,n2)
Ind_warm <- seq(1,365)  
str(Ind_Run)

RunOptions <- CreateRunOptions(FUN_MOD = RunModel_GR4J,
                               InputsModel = InputsModel, IndPeriod_Run = Ind_Run,
                               IniStates = NULL, IniResLevels = NULL, IndPeriod_WarmUp = Ind_warm)

OutputsModel <- RunModel_GR4J(InputsModel = InputsModel, RunOptions = RunOptions, Param = Param)
str(OutputsModel)
plot(OutputsModel)
