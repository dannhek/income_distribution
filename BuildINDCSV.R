#Get Individual Data
library(DBI)
setwd("~/R Income Distribution/CPS Data")

options(survey.replicates.mse = TRUE)
dbfolder <- paste0( getwd() , "/MonetDB" )
db <- dbConnect( MonetDBLite() , dbfolder )

query2015 <- "select peridnum, h_year, pearnval
from asec15 where wsal_val <> 0"
df2015 <- dbGetQuery(db, query2015)

query2010 <- "select peridnum, h_year, pearnval
from asec10 where wsal_val <> 0"
df2010 <- dbGetQuery(db, query2010)

query2005 <- "select peridnum, h_year, pearnval
from asec05 where wsal_val <> 0"
df2005 <- dbGetQuery(db, query2005)

query2000 <- "select concat(h_idnum, a_lineno), h_year, pearnval
from asec00 where wsal_val <> 0"
df2000 <- dbGetQuery(db, query2000)

##Adjust for Inflation
getSymbols("CPIAUCSL", src='FRED')
avg.cpi <- apply.yearly(CPIAUCSL, mean)   #arithmetic mean
cf <- avg.cpi/as.numeric(avg.cpi['2015']) #using 2015 as the base year

names(df2000) <- c("p_id","year","p_income")
names(df2005) <- c("p_id","year","p_income")
names(df2010) <- c("p_id","year","p_income")
names(df2015) <- c("p_id","year","p_income")


dfFull <- rbind(df2015,df2010,df2005,df2000)
dfFull$year <- as.character(dfFull$year)
cf <- as.data.frame(cf)
rownames(cf) <- year(rownames(cf))
names(cf) <- "cpi_adj"
dfFull <- merge(dfFull,cf,by.x="year",by.y="row.names")
dfFull$adj_p_income <- dfFull$p_income * dfFull$cpi_adj

##Write to File
write.csv(dfFull, "indvwagessalary.csv")

dbDisconnect(db)

# q1 <- "select count(*) from asec00 where pearnval<> 0 and precord = 3"
# q2 <- "select count(*) from asec05 where pearnval<> 0 and precord = 3"
# q3 <- "select count(*) from asec10 where pearnval<> 0 and precord = 3"
# q4 <- "select count(*) from asec15 where pearnval<> 0 and precord = 3"
# q5 <- "select count(*) from asec00 where precord = 3"
# q6 <- "select count(*) from asec05 where precord = 3"
# q7 <- "select count(*) from asec10 where precord = 3"
# q8 <- "select count(*) from asec15 where precord = 3"
# data.frame( a2000 = c(dbGetQuery(db,q1),dbGetQuery(db,q5))
#             ,a2005 = c(dbGetQuery(db,q2),dbGetQuery(db,q6))
#             ,a2010 = c(dbGetQuery(db,q3),dbGetQuery(db,q7))
#             ,a2015 = c(dbGetQuery(db,q4),dbGetQuery(db,q8))
# )

