library(ggplot2) ; set.seed(100)
sample1<-data.frame(x=runif(100,0,2))
sample2<-data.frame(x=rnorm(100,1,.33))
dist1  <-density(sample1$x,from=0,to=2)
dist2  <-density(sample2$x,from=0,to=2)
df1    <-data.frame(x=dist1$x,y=dist1$y)
df2    <-data.frame(x=dist2$x,y=dist2$y)
df3    <-data.frame(x=dist1$x,y=dist1$y-dist2$y)
shadeR <-rbind

p <- ggplot() +
     scale_x_continuous(limits=c(0,2)) +
     #geom_line(data=df1,aes(x,y),size=1.4,colour="blue")  +
     #geom_line(data=df2,aes(x,y),size=1.4,colour="green") +
     geom_line(data=df3,aes(x,y),size=1.4,colour="black")   +
     geom_area(data=subset(df3,y>0),aes(x=x,y=y),alpha=0.5,fill="green")+
     geom_area(data=subset(df3,y<0),aes(x=x,y=y),alpha=0.5,fill="red")+
     geom_hline(yintercept=0); p


