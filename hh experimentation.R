library(ggplot2)
library(DBI)
library(MonetDB.R)
library(MonetDBLite)
setwd("~/R Income Distribution")
df <- read.csv("CPS Data/hhwagessalary.csv")

dim(df)
table(df$year)

getClass <- function(income,year,compare) {
     compare <- subset(compare,year==year)
     if (income < compare$lower) return("lower")
     if (income >=compare$upper) return("upper")
     else (return("middle"))
}
for (i in c(1:nrow(df))) {
     df$seclass[i] <- getClass(df$adj_h_income[i],df$year[i],ses.bounds)
}

addmargins(table(df$year,df$seclass))
prop.table(table(df$year,df$seclass),1)


setwd("~/R Income Distribution/CPS Data")
options(survey.replicates.mse = TRUE)

allCols <- names(dbGetQuery(db,"select * from asec15 limit 1"))

overtimeDF <- dbGetQuery(db,"select distinct asec15.h_idnum1,asec15.hhinc,asec00.hhinc,asec00.a_age,asec15.a_age
                      from asec15
                      inner join asec00 on asec15.h_idnum1 = asec00.h_idnum and 
                      where asec00.a_age > 18")
overtimeDF


adultHHIncome <- dbGetQuery(db,"select h_idnum1,peridnum,h_numper,a_age,htotval
                              from asec15 where a_age > 18")
adultHHIncome$adj_income <- round(adultHHIncome$htotval / sqrt(adultHHIncome$h_numper), digits = 2)

for (i in c(1:nrow(adultHHIncome))) {
     adultHHIncome$seclass[i] <- getClass(adultHHIncome$adj_income[i],2015,ses.bounds)
}
adultHHIncome
round(100*prop.table(table(subset(adultHHIncome,adj_income > 0)$seclass)),digits=2)

