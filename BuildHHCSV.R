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
# cps.years.to.download <- c(2015,2010,2005,2000)
# source_url( "https://raw.githubusercontent.com/ajdamico/asdfree/master/Current%20Population%20Survey/download%20all%20microdata.R" , prompt = FALSE , echo = TRUE )

options(survey.replicates.mse = TRUE)
dbfolder <- paste0( getwd() , "/MonetDB" )
db <- dbConnect( MonetDBLite() , dbfolder )

query2015 <- "select h_idnum1, h_year, max(hwsval), max(htotval), 
               max(h_numper), max(h_numper-hunder18), sum(case when earner=1 then 1 else 0 end), max(hnumfam)
               from asec15 where htotval > 0 group by h_idnum1,h_year"
df2015 <- dbGetQuery(db, query2015)


query2010 <- "select h_idnum1, h_year, max(hwsval), max(htotval), 
               max(h_numper), max(h_numper-hunder18), sum(case when earner=1 then 1 else 0 end), max(hnumfam)
               from asec10 where htotval > 0 group by h_idnum1,h_year"
df2010 <- dbGetQuery(db, query2010)


query2005 <- "select h_idnum1, h_year, max(hwsval), max(htotval), 
               max(h_numper), max(h_numper-hunder18), sum(case when earner=1 then 1 else 0 end), max(hnumfam)     
               from asec05 where htotval > 0 group by h_idnum1,h_year"
df2005 <- dbGetQuery(db, query2005)


query2000 <- "select h_idnum, h_year, max(hwsval), max(htotval), 
               max(h_numper), max(h_numper-hunder18), sum(case when earner=1 then 1 else 0 end), max(hnumfam)        
               from asec00 where htotval > 0 group by h_idnum,h_year"
df2000 <- dbGetQuery(db, query2000)


names(df2000) <- c("h_id","year","h_wages","h_income","h_size","h_num_adults","h_num_earners","h_num_fams")
names(df2005) <- c("h_id","year","h_wages","h_income","h_size","h_num_adults","h_num_earners","h_num_fams")
names(df2010) <- c("h_id","year","h_wages","h_income","h_size","h_num_adults","h_num_earners","h_num_fams")
names(df2015) <- c("h_id","year","h_wages","h_income","h_size","h_num_adults","h_num_earners","h_num_fams")

##Adjust for Inflation
setwd("~/R Income Distribution/CPS Data")
getSymbols("CPIAUCSL", src='FRED')
avg.cpi <- apply.yearly(CPIAUCSL, mean)   #arithmetic mean
cf <- avg.cpi/as.numeric(avg.cpi['2015']) #using 2015 as the base year

dfFull <- rbind(df2015,df2010,df2005,df2000)
dfFull$year <- as.character(dfFull$year)
cf <- as.data.frame(cf)
rownames(cf) <- year(rownames(cf))
names(cf) <- "cpi_adj"
dfFull <- merge(dfFull,cf,by.x="year",by.y="row.names")
dfFull$adj_h_income <- (dfFull$h_income / dfFull$cpi_adj) 

##Adjust for Household Size
dfFull <- subset(dfFull,h_size > 0)
dfFull$adj_h_income <- dfFull$adj_h_income / sqrt(dfFull$h_size)

##Add Income Categorization of Lower-Middle-Upper
#Get Lower/Middle/Upper Groups
df$year        <- as.factor(as.character(df$year))
df$adj_h_income    <- as.numeric(df$adj_h_income)
ses.bounds <- data.frame(year=NULL, median=NULL, lower=NULL, upper=NULL)
for (yr in c('2015', '2010', '2005', '2000')) {
     med <- median(subset(df,year==yr)$adj_h_income)
     ses.bounds <- rbind(ses.bounds,data.frame(
          year=yr,
          median=med,
          lower=med*0.67,
          upper=med*2)
     )
}
getClass <- function(income,year,compare) {
     compare <- subset(compare,year==year)
     if (income < compare$lower) return("lower")
     if (income >=compare$upper) return("upper")
     else (return("middle"))
}
for (i in c(1:nrow(dfFull))) {
     dfFull$seclass[i] <- getClass(dfFull$adj_h_income[i],dfFull$year[i],ses.bounds)
}

##Write to File
write.csv(dfFull, "hhwagessalary.csv")

dbDisconnect(db)
