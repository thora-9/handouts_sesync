library(airGR)
library(zoo)
library(lubridate)


setwd('C:/Users/tejasvi/Dropbox/School Notes Laptop/Fall 2018/Github_Sesync/Raven_GR4J/airGR')

input = read.csv('out_all_v4.csv',stringsAsFactors = FALSE)
colnames(input)[6] = 'Flow'
colnames(input)[13] = 'Precipitation'
colnames(input)[20] = 'Temperature'

dates_v1 = as.character(input$)
dates_v2 = as.POSIXct(dates_v1,tz = "",'%Y-%m-%d')
jd = yday(dates_v2)

data(L0123001)

PE_data = PEdaily_Oudin(jd, input$Temperature, Lat = 13)
precip = as.numeric(input$Precipitation)
precip[is.na(precip)] = 0
flow = as.numeric(input$Flow)
Makana_BV = 22000*1000000
flow_mmday2 = 1000*(flow*24*60*60)/Makana_BV
flow_mmday[(flow_mmday2< quantile(flow_mmday,0.25,na.rm = TRUE))|
             (flow_mmday2 > quantile(flow_mmday,0.75,na.rm = TRUE))] = NA



InputsModel <- CreateInputsModel(FUN_MOD = RunModel_GR4J, DatesR = dates_v2,
                                 Precip = precip, PotEvap = PE_data)
str(InputsModel)

Ind_Run <- seq(366,1461)
Ind_warm <- seq(1,365)  
str(Ind_Run)

RunOptions <- CreateRunOptions(FUN_MOD = RunModel_GR4J,
                               InputsModel = InputsModel, IndPeriod_Run = Ind_Run,
                               IniStates = NULL, IniResLevels = NULL, IndPeriod_WarmUp = Ind_warm)
str(RunOptions)

InputsCrit <- CreateInputsCrit(FUN_CRIT = ErrorCrit_NSE, InputsModel = InputsModel, 
                               RunOptions = RunOptions, Qobs = flow_mmday[Ind_Run])
str(InputsCrit)

CalibOptions <- CreateCalibOptions(FUN_MOD = RunModel_GR4J, FUN_CALIB = Calibration_Michel)
str(CalibOptions)

OutputsCalib <- Calibration_Michel(InputsModel = InputsModel, RunOptions = RunOptions,
                                   InputsCrit = InputsCrit, CalibOptions = CalibOptions,
                                   FUN_MOD = RunModel_GR4J, FUN_CRIT = ErrorCrit_NSE)
Param <- OutputsCalib$ParamFinalR
Param

OutputsModel <- RunModel_GR4J(InputsModel = InputsModel, RunOptions = RunOptions, Param = Param)
str(OutputsModel)
k
plot(OutputsModel, Qobs = flow_mmday2[Ind_Run])
