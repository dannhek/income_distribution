library(ggplot2)
setwd("~/R Income Distribution")
df <- read.csv("CPS Data/indvwagessalary.csv")

df$year        <- as.factor(as.character(df$year))
df$adj_p_income    <- as.numeric(df$adj_p_income)

#Graph 1 - All years
allyears <- ggplot(df, aes(x=adj_p_income, colour=year)) +
               geom_density() +
               xlim(0,500000) +
               geom_vline(xintercept = mean(df$p_income), colour="black") +
               geom_vline(xintercept = median(df$p_income), colour="blue")
allyears

#Graph 2 - 2015 compared to 2000
dist1 <- density(subset(df,year == 2000, adj_p_income)$adj_p_income,from=0,to=500000)
dist2 <- density(subset(df,year == 2015, adj_p_income)$adj_p_income,from=0,to=500000)
df1    <-data.frame(x=dist1$x,y=dist2$y-dist1$y)
compareYears <- ggplot() +
     scale_x_continuous(limits=c(0,750000)) +
     geom_line(data=df1,aes(x,y),size=1,colour="black")   +
     geom_area(data=subset(df1,y>0),aes(x=x,y=y),alpha=0.5,fill="lightgreen")+
     geom_area(data=subset(df1,y<0),aes(x=x,y=y),alpha=0.5,fill="pink")+
     geom_hline(yintercept=0)
compareYears
