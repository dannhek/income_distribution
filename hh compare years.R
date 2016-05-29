library(ggplot2) ; library(scales)
setwd("~/R Income Distribution")
df <- read.csv("CPS Data/hhwagessalary.csv")

df$year        <- as.factor(as.character(df$year))
df$adj_h_income    <- as.numeric(df$adj_h_income)

#Get Lower/Middle/Upper Groups
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
for (i in c(1:nrow(df))) {
     df$seclass[i] <- getClass(df$adj_h_income[i],df$year[i],ses.bounds)
}


#Graph 1 - All years
allyears <- ggplot(df, aes(x=adj_h_income, colour=year)) +
               geom_density() +
               xlim(0,750000) +
               geom_vline(xintercept = mean(df$adj_h_income), colour="black") +
               geom_vline(xintercept = median(df$adj_h_income), colour="blue")
allyears

#Graph 2 - 2015 compared to 2000
dist1 <- density(subset(df,year == 2000, adj_h_income)$adj_h_income,from=0,to=1000000)
dist2 <- density(subset(df,year == 2015, adj_h_income)$adj_h_income,from=0,to=1000000)
df1    <-data.frame(x=dist1$x,y=dist2$y-dist1$y)
compareYears <- ggplot() +
     scale_x_continuous(limits=c(0,750000),labels=comma,breaks=seq(0,750000,by=50000)) +
     geom_line(data=df1,aes(x,y),size=1,colour="black")   +
     geom_area(data=subset(df1,y>0),aes(x=x,y=y),alpha=0.5,fill="lightgreen")+
     geom_area(data=subset(df1,y<0),aes(x=x,y=y),alpha=0.5,fill="pink")+
     geom_hline(yintercept=0)+
     geom_vline(xintercept=ses.bounds$median[1])

compareYears

#Graph 3 - Class Distribution
classes <- ggplot() +
     geom_bar(data=df,aes(fill=seclass,x=year),position="fill") + 
     coord_flip() #+ geom_text(aes(label=percent))
classes
