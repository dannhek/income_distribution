setwd("~/R Income Distribution")
df <- read.csv("CPS Data/hhwagessalary.csv")

df$year        <- as.factor(as.character(df$year))
df$adj_h_income    <- as.numeric(df$adj_h_income)

#Graph 1 - All years
allyears <- ggplot(df, aes(x=adj_h_income, colour=year)) +
               geom_density() +
               xlim(0,750000) +
               geom_vline(xintercept = mean(df$h_income), colour="black") +
               geom_vline(xintercept = median(df$h_income), colour="blue")
allyears

#Graph 2 - 2015 compared to 2000
dist1 <- density(subset(df,year == 2000, adj_h_income)$adj_h_income,from=0,to=1000000)
dist2 <- density(subset(df,year == 2015, adj_h_income)$adj_h_income,from=0,to=1000000)
df1    <-data.frame(x=dist1$x,y=dist2$y-dist1$y)
compareYears <- ggplot() +
     scale_x_continuous(limits=c(0,750000)) +
     geom_line(data=df1,aes(x,y),size=1,colour="black")   +
     geom_area(data=subset(df1,y>0),aes(x=x,y=y),alpha=0.5,fill="lightgreen")+
     geom_area(data=subset(df1,y<0),aes(x=x,y=y),alpha=0.5,fill="pink")+
     geom_hline(yintercept=0)
compareYears
