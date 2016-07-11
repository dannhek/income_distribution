library(ggplot2)
library(DBI)
library(MonetDB.R)
library(MonetDBLite)
library(RColorBrewer)
setwd("~/R Income Distribution")
df <- read.csv("CPS Data/hhwagessalary.csv")

dim(df)
table(df$year)

# getClass <- function(income,year,compare) {
#      compare <- subset(compare,year==year)
#      if (income < compare$lower) return("lower")
#      if (income >=compare$upper) return("upper")
#      else (return("middle"))
# }
# for (i in c(1:nrow(df))) {
#      df$seclass[i] <- getClass(df$adj_h_income[i],df$year[i],ses.bounds)
# }
# write.csv(df,"CPS Data/hhwagessalary.csv")

addmargins(table(df$year,df$seclass))
prop.table(table(df$year,df$seclass),1)

linecolors  <- brewer.pal(4,"Set1")
medianlines <- ggplot() + geom_vline(xintercept=ses.bounds[1,3],color=linecolors[1],alpha=0.5) +
     geom_vline(xintercept=ses.bounds[1,4],color=linecolors[1],alpha=0.5) +
     geom_vline(xintercept=ses.bounds[2,3],color=linecolors[2],alpha=0.5) +
     geom_vline(xintercept=ses.bounds[2,4],color=linecolors[2],alpha=0.5) +
     geom_vline(xintercept=ses.bounds[3,3],color=linecolors[3],alpha=0.5) +
     geom_vline(xintercept=ses.bounds[3,4],color=linecolors[3],alpha=0.5) +
     geom_vline(xintercept=ses.bounds[4,3],color=linecolors[4],alpha=0.5) +
     geom_vline(xintercept=ses.bounds[4,4],color=linecolors[4],alpha=0.5) 
medianlines


setwd("~/R Income Distribution/CPS Data")
options(survey.replicates.mse = TRUE)

allCols <- names(dbGetQuery(db,"select * from asec15 limit 1"))

overtimeDF <- dbGetQuery(db,"select distinct asec15.h_idnum1,asec15.hhinc,asec00.hhinc,asec00.a_age,asec15.a_age
                      from asec15
                      inner join asec00 on asec15.h_idnum1 = asec00.h_idnum  
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



dbGetQuery(db,"select h_idnum1,htotval from asec15")





#Graph 3 - Adult Class Distribution
classesGraph <- function(df,column) {
     val<-deparse(substitute(column))
tbl<-ddply(df, ~ year+seclass, summarise,numAdults=sum(val))
tbl<-dcast(tbl,year~seclass,sum) ; rownames(tbl)<-tbl$year
tbl$year <- NULL ; tbl<-tbl/rowSums(tbl) ; tbl$year <- rownames(tbl)
adultClassProps <- melt(tbl, id="year") 
adultClassProps <- mutate(group_by(adultClassProps,year),pos=cumsum(value)-.5*value)
names(adultClassProps) <- c("year","income","prop","pos")

classes <- ggplot(data=adultClassProps,aes(fill=income,x=year,y=prop)) +
     geom_bar(stat="identity") + 
     geom_text(y=adultClassProps$pos,aes(label=paste0(round(100*prop),"%")),size=2) +
     coord_flip() 
classes
}
classesGraph(df,h_size)




query2015 <- "select h_idnum1, h_year, max(hwsval), max(htotval), 
               max(h_numper), max(h_numper-hunder18), sum(case when earner=1 then 1 else 0 end)
from asec15 where htotval > 0 group by h_idnum1,h_year"
df2015 <- dbGetQuery(db, query2015)


dbGetQuery(db,"select count(*) from asec15 where frecord=1")
dbGetQuery(db,"select count(*) from asec15 where hrecord=1")
dbGetQuery(db,"select count(*) from asec15 where precord=1")
