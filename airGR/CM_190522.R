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

inflow = zoo(as.numeric(input$Flow), input$Date2)



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


#Constants

#Variable




