require(dplyr)
require(reshape2)
require(lubridate)

flow_data = read.csv('Bafing_9697.csv')

fl_long = melt(flow_data, id.vars = c("Station", "Year", 'Day'))
cur_data = fl_long
i = 1
for (i in 1:nrow(fl_long)){
  cur_month = as.character(cur_data$variable[i])
  if (cur_month == 'January' | cur_month == 'February'|  cur_month  == 'March'|  cur_month  == 'April'){
    cur_data$Year[i] = cur_data$Year[i] + 1
  }
}

cur_data$Date = paste(cur_data$Year,cur_data$variable,cur_data$Day,sep = '-')
cur_data$Date2 = as.Date(cur_data$Date,'%Y-%B-%d')
cur_data = cur_data[complete.cases(cur_data), ]
out_data_fl = cur_data %>% arrange(Date2)

precip_data = read.csv('Precip_Bafing.csv',stringsAsFactors = FALSE)

pr_long = melt(precip_data, id.vars = c("Station", "Year", 'Day'))
cur_data = pr_long
i = 1
for (i in 1:nrow(pr_long)){
  cur_month = as.character(cur_data$variable[i])
  if (cur_month == 'January' | cur_month == 'February'|  cur_month  == 'March'|  cur_month  == 'April'){
    cur_data$Year[i] = cur_data$Year[i] + 1
  }
}

cur_data$Date = paste(cur_data$Year,cur_data$variable,cur_data$Day,sep = '-')
cur_data$Date2 = as.Date(cur_data$Date,'%Y-%B-%d')
cur_data = cur_data[complete.cases(cur_data), ]
out_data_pr = cur_data %>% arrange(Date2)

temp_data = read.csv('Mean_Temp_Manantali.csv',stringsAsFactors = FALSE)

tm_long = melt(temp_data, id.vars = c("Station", "Year", 'Day'))
cur_data = tm_long
i = 1
for (i in 1:nrow(tm_long)){
  cur_month = as.character(cur_data$variable[i])
  if (cur_month == 'January' | cur_month == 'February'|  cur_month  == 'March'|  cur_month  == 'April'){
    cur_data$Year[i] = cur_data$Year[i] + 1
  }
}

cur_data$Date = paste(cur_data$Year,cur_data$variable,cur_data$Day,sep = '-')
cur_data$Date2 = as.Date(cur_data$Date,'%Y-%B-%d')
cur_data = cur_data[complete.cases(cur_data), ]
out_data_tm = cur_data %>% arrange(Date2)

out_all1 = cbind(out_data_fl,out_data_pr,out_data_tm)
write.csv(out_all1,'out_all_v2.csv')

