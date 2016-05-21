#Build Data Frame

#install.packages( c( "MonetDB.R" , "MonetDBLite" , "devtools" , "survey" , "SAScii" , "descr" , "downloader" , "digest" , "haven" , "devtools" )  )
#install_github( "biostatmatt/sas7bdat.parso" )
#install.packages("quantmod") #for inflation adjustment later

library(devtools)
library(DBI)			# load the DBI package (implements the R-database coding)
library(MonetDB.R)			# load the MonetDB.R package (connects r to a monet database)
library(MonetDBLite)		# load MonetDBLite package (creates database files in R)
library(survey)				# load survey package (analyzes complex design surveys)
library(SAScii) 			# load the SAScii package (imports ascii data with a SAS script)
library(descr) 				# load the descr package (converts fixed-width files to delimited files)
library(downloader)			# downloads and then runs the source() function on scripts from github
library(haven) 				# load the haven package (imports dta files faaaaaast)
library(sas7bdat.parso) 	# load the sas7bdat.parso (imports binary/compressed sas7bdat files)
library(quantmod)

setwd("~/R Income Distribution/CPS Data")
cps.years.to.download <- c(2015,2010,2005,2000)
source_url( "https://raw.githubusercontent.com/ajdamico/asdfree/master/Current%20Population%20Survey/download%20all%20microdata.R" , prompt = FALSE , echo = TRUE )

options(survey.replicates.mse = TRUE)
dbfolder <- paste0( getwd() , "/MonetDB" )
db <- dbConnect( MonetDBLite() , dbfolder )

query2015 <- "select h_idnum1, h_year, max(hwsval) 
               from asec15 where hwsval <> 0 group by h_idnum1,h_year"
df2015 <- dbGetQuery(db, query2015)


query2010 <- "select h_idnum1, h_year, max(hwsval) 
               from asec10 where hwsval <> 0 group by h_idnum1,h_year"
df2010 <- dbGetQuery(db, query2010)


query2005 <- "select h_idnum1, h_year, max(hwsval)           
               from asec05 where hwsval <> 0 group by h_idnum1,h_year"
df2005 <- dbGetQuery(db, query2005)


query2000 <- "select h_idnum as 'h_idnum1', h_year, max(hwsval)           
               from asec00 where hwsval <> 0 group by h_idnum,h_year"
df2000 <- dbGetQuery(db, query2000)

names(df2000) <- c("h_id","year","h_income")
names(df2005) <- c("h_id","year","h_income")
names(df2010) <- c("h_id","year","h_income")
names(df2015) <- c("h_id","year","h_income")

##Adjust for Inflation
setwd("~/R Income Distribution/CPS Data")
getSymbols("CPIAUCSL", src='FRED')
avg.cpi <- apply.yearly(CPIAUCSL, mean)   #arithmetic mean
cf <- avg.cpi/as.numeric(avg.cpi['2015']) #using 2015 as the base year

dfFull <- rbind(df2015,df2010,df2005,df2000)
dfFull$year <- as.character(dfFull$year)
dfFull$cpi_adj      <- cf[dfFull$year]
dfFull$adj_h_income <- dfFull$h_income * dfFull$cpi_adj

##Write to File
write.csv(dfFull, "hhwagessalary.csv")


