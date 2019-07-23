library(mosaic)
library(nlstools)

in_data = read.csv('H_Pmax_Qmin.csv')

#Stage-Volume Relationship
plot(in_data$H,in_data$Pmax)

in_sub = subset(in_data, H<203)

f = lm(Pmax~poly(H,4), data = in_data)

in_x = seq(150,203,by=1)

plot(in_x, predict(f,list(H=in_x)),type = 'l')#, ylim = c(0,16),col='red',xlab = "Stage Height (m)", ylab = "Volume (km3)")
points(in_sub$H,in_sub$Pmax)

#save(f,file='H_model.rda')

#Stage-Volume Relationship
plot(in_data$H,in_data$Qmin)

in_sub2 = subset(in_data, H<208)

f2 = lm(Qmin~poly(H,10), data = in_sub2)

in_x = seq(170,203,by=1)

plot(in_x, predict(f2,list(H=in_x)),type = 'l')#, ylim = c(0,16),col='red',xlab = "Stage Height (m)", ylab = "Volume (km3)")
points(in_sub$H,in_sub$Qmin)

#save(f2,file='Q_min_H_max.rda')

in_sub2 = subset(in_data, H>207)

f3 = lm(Qmin~poly(H,1), data = in_sub2)

in_x = seq(208,210,by=0.1)

plot(in_x, predict(f3,list(H=in_x)),type = 'l')#, ylim = c(0,16),col='red',xlab = "Stage Height (m)", ylab = "Volume (km3)")
points(in_sub2$H,in_sub2$Qmin)

#save(f3,file='Q_min_H_max_208.rda')
