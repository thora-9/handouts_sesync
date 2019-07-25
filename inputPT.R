library(dplyr)
library(data.table)
library(zoo)
library(lubridate)
MaliTemp <- fread('Mali_Temperature.csv')
MaliTemp <- MaliTemp %>%
  select(
    STATION,
    LATITUDE,
    LONGITUDE,
    DATE,
    TAVG
  )
MaliTemp <- MaliTemp %>%
  filter(
    STATION == 'MLM00061291'
  )

SenPrec <- fread('Senegal_Precip.csv')
SenPrec <- SenPrec %>%
  select(
    STATION,
    LATITUDE,
    LONGITUDE,
    DATE,
    PRCP
  )
SenPrec <- SenPrec %>%
  filter(
    STATION == 'SGM00061600'
  )

# Use zoo to index by date and merge
MaliTemp.Date <- as.Date(MaliTemp$DATE, 
  format = "%Y-%m-%d"
  )
mtz <- zoo(MaliTemp$TAVG, MaliTemp.Date)

SenPrec.Date <- as.Date(SenPrec$DATE, 
  format = "%Y-%m-%d"
)
spz <- zoo(SenPrec$PRCP, SenPrec.Date)

mtp <- merge(mtz, spz, all = FALSE)
saveRDS(mtp, "InputPT_test_1975_2016.rds")
write.csv(mtp, "InputPT_test_1975_2016.csv")
