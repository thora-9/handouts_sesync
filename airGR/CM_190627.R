library(airGR)
library(zoo)
library(lubridate)
#require(Kendall)
require(hydroTSM)
require(tibble)
require(dplyr)
require(hydroGOF)
require(ggplot2)
require(ggpubr)
require(zyp)
require(reshape2)

source("stage_vol.R")
source("stage_area.R")
source("vol_stage.R")
source("Q_max.R")
source("H_max.R")
load("H_model.rda")
load("Q_min_H_max.rda")
load('Q_min_H_max_208.rda')
load('Q_min_H_50.rda')
load('Q_min_H_100.rda')
#####################Flow and precipitation data
setwd('C:/Users/tejasvi/Dropbox/School Notes Laptop/Fall 2018/Github_Sesync/Raven_GR4J/airGR')

input = read.csv('out_all_v4.csv',stringsAsFactors = FALSE)
colnames(input)[6] = 'Flow'
colnames(input)[13] = 'Precipitation'
colnames(input)[20] = 'Temperature'

dates_v1 = as.character(input$Date2)
dates_v2 = as.POSIXct(dates_v1,tz = "",'%Y-%m-%d')
jd = yday(dates_v2)


precip = zoo(as.numeric(input$Precipitation), input$Date2)
precip[is.na(precip)] = 0
#Currently directly plotting the precip data gives errors; use core data to plot

#inflow = zoo(OutputsModel$Qsim, input$Date2[Ind_Run])*(27800/10^6)#zoo(as.numeric(input$Flow), input$Date2)
inflow = zoo(as.numeric(input$Flow), input$Date2)#*(24*60*60)/10^9


################ET data
ET_input = read.csv('ET_loss.csv', stringsAsFactors = FALSE)
ET_input$perday = as.numeric(ET_input$ET_loss_Manantali_Reservoir_mm_month)/30


###############Max Limit Data
max_lim = read.csv('Max_Limit_Manantali.csv', stringsAsFactors = FALSE)
max_lim2 = melt(max_lim, id.vars = ('X'))
max_lim3 = max_lim2[complete.cases(max_lim2),]
max_lim3$monday = paste(max_lim3$X,max_lim3$variable,sep='-')
max_lim3$date = as.Date(max_lim3$monday,format = '%d-%B')
max_lim3$jd = yday(max_lim3$date)


###############Min Limit Data
min_lim = read.csv('Min_Limit_Manantali.csv', stringsAsFactors = FALSE)
min_lim2 = melt(min_lim, id.vars = ('X'))
min_lim3 = min_lim2[complete.cases(min_lim2),]
min_lim3$monday = paste(min_lim3$X,min_lim3$variable,sep='-')
min_lim3$date = as.Date(min_lim3$monday,format = '%d-%B')
min_lim3$jd = yday(min_lim3$date)

plot(max_lim3$value,ylim = c(150,215))
points(min_lim3$value)
points(stage[1:365])

#Constants
HP = vector()
ET = vector()
Q = vector()
Q_vol = vector()
infl_vol = vector()
outfl_vol = vector()
pr_vol = vector()
Qmax2 = vector()

stage = vector()
vol = vector()
area = vector()


WL_in = 184
i = 1

for (i in 1:length(precip)){
  cur_precip = coredata(precip[i])
  cur_date = index(precip[i])
  cur_month = month(cur_date)
  cur_day = yday(index(precip[i]))
  if (cur_day == 366){
    cur_day = 365
  }
  
  if (i == 1){
    cur_stage = WL_in
  } else {
    cur_stage = stage[i-1]
  }
  
  #Volume in km3 / stage in m
  cur_vol = stage_vol(cur_stage)
  #Area in km2 / stage in m
  cur_area = stage_area(cur_stage)

  temp_ET = subset(ET_input,ET_input$Month.1 == cur_month)
  cur_ET = temp_ET$perday 
  ET_vol = (cur_ET*cur_area)/(1000*1000)
  
  precip_vol = (cur_precip*cur_area)/(1000*1000)
  pr_vol[i] = precip_vol
  
  #m3/sec to km3/day
  cur_inflow = (coredata(inflow[i])*24*60*60)/(10^9) #coredata(inflow[i])
  infl_vol [i] = cur_inflow
  
  #Reservoir WL
  temp_min = subset(min_lim3, jd == cur_day)
  cur_min = temp_min$value
  
  temp_max = subset(max_lim3, jd == cur_day)
  cur_max = temp_max$value
  Qmax2[i] = cur_max

  if (cur_stage > cur_max){
    cur_Q = Qmax(cur_stage)
  } else if (cur_stage < cur_min | cur_stage < 197){
    cur_H = 0
    cur_Q = 10
  } else if (cur_stage < 204){
    temp_x = data.frame(H=cur_stage)
    cur_H = 50#predict(f,temp_x)
    cur_Q = predict(f_50,temp_x)
  } else if (cur_stage >= 204 & cur_stage<208){
    temp_x = data.frame(H=cur_stage)
    cur_H = 205
    cur_Q = predict(f2,temp_x)
  } else if (cur_stage >= 208){
    temp_x = data.frame(H=cur_stage)
    cur_H = 205
    cur_Q = predict(f3,temp_x)
  }
  
  Q_vol[i] = (cur_Q*24*60*60)/(10^9)
  Q[i] = cur_Q
  
  ET[i] = ET_vol
  
  HP[i] = cur_H
  
  vol[i] = cur_vol + precip_vol - ET_vol - Q_vol[i] + cur_inflow
  
  outfl_vol[i] =  ET_vol + Q_vol[i]
  
  stage[i] = vol_stage(vol[i])

}


#Variable
plot(stage)
stage_zoo = zoo(stage,as.Date(index(precip)))
#test = izoo2rzoo(stage_zoo,tstep = "days",from = "1996-05-01",to="2000-04-30")
stage_mon = daily2monthly(stage_zoo, FUN = mean)
stage2 = diff(stage_mon)


plot(stage_mon)
plot(Q)
plot(Qmax2, ylim = c(170,215))

plot(HP)

sum(Q_vol)
sum(pr_vol)
sum(ET_vol)
sum(infl_vol)
