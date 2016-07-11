library(ggplot2) ; library(scales) ; library(RColorBrewer) 
library(plyr) ; library(dplyr) ; library(reshape2)
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
# getClass <- function(income,year,compare) {
#      compare <- subset(compare,year==year)
#      if (income < compare$lower) return("lower")
#      if (income >=compare$upper) return("upper")
#      else (return("middle"))
# }
# for (i in c(1:nrow(df))) {
#      df$seclass[i] <- getClass(df$adj_h_income[i],df$year[i],ses.bounds)
# }
# 
linecolors  <- brewer.pal(4,"Set1")



#Graph 1 - All years
allyears <- ggplot(df, aes(x=adj_h_income, colour=year)) + geom_density() +
     ggtitle("Adjusted Household Income Distribution Over Time") +
     xlab("Adjusted Household Income (2015 USD)") +
     ylab("Density") + 
     scale_x_continuous(labels=comma,limits=c(0,500000),
                        breaks=c(0,50000,100000,200000,300000,400000,500000))+
     scale_y_continuous(labels=comma)

allyears


#Graph 2 - 2015 compared to Previous Years
getYearComparison <- function(df,year1=2000,year2=2015) {
     dist1 <- density(subset(df,year == year1, adj_h_income)$adj_h_income,from=0,to=1000000)
     dist2 <- density(subset(df,year == year2, adj_h_income)$adj_h_income,from=0,to=1000000)
     df1    <-data.frame(x=dist1$x,y=dist2$y-dist1$y) ; df1$pos <- df1$y>0
     
     compareYears <- ggplot(data=df1) +
          geom_line(aes(x=x,y=y),size=1,colour="black")   +
          geom_area(aes(x=x,y=ifelse(y>0,y,0),ymin=0),alpha=0.5,fill="lightgreen")+
          geom_area(aes(x=x,y=ifelse(y<0,y,0),ymax=0),alpha=0.5,fill="pink")+
          geom_hline(yintercept=0)+
          ggtitle(paste0("Changes in Income Distribution Between ",year1," and ",year2)) +
          xlab("Adjusted Household Income (2015 USD)") +
          ylab("Difference in Distribution Density") +
          scale_x_continuous(labels=comma,limits=c(0,500000),breaks=c(0,50000,100000,200000,300000,400000,500000)) +
          scale_y_continuous(labels=comma) +
          scale_fill_brewer(palette="Set3")
     
     list(graph=compareYears,dataframe=df1)
}
getYearComparison(df)


ddply(df,~year+seclass,summarise,minincome=min(adj_h_income),maxincome=max(adj_h_income),medincom=median(adj_h_income),avgsize=mean(h_size))

#Graph 3 - Adult Class Distribution
tbl<-ddply(df, ~ year+seclass, summarise,numAdults=sum(h_num_adults))
tbl<-dcast(tbl,year~seclass,sum) ; rownames(tbl)<-tbl$year
tbl$year <- NULL ; tbl<-tbl/rowSums(tbl) ; tbl$year <- rownames(tbl)
ClassProps <- melt(tbl, id="year") 
ClassProps <- mutate(group_by(ClassProps,year),pos=cumsum(value)-.5*value)
names(ClassProps) <- c("year","income","prop","pos")

adult.income.class <- ggplot(data=ClassProps,aes(fill=income,x=year,y=prop)) +
     geom_bar(stat="identity") + 
     geom_text(y=ClassProps$pos,aes(label=paste0(round(100*prop),"%")),size=2) +
     coord_flip() + ggtitle("Distribution of Adults by Income Class") +
     xlab("Proportion") + ylab("Year")
adult.income.class


#Graph 4 - All Population Class Distribution
tbl<-ddply(df, ~ year+seclass, summarise,numAdults=sum(h_size))
tbl<-dcast(tbl,year~seclass,sum) ; rownames(tbl)<-tbl$year
tbl$year <- NULL ; tbl<-tbl/rowSums(tbl) ; tbl$year <- rownames(tbl)
ClassProps <- melt(tbl, id="year") 
ClassProps <- mutate(group_by(ClassProps,year),pos=cumsum(value)-.5*value)
names(ClassProps) <- c("year","income","prop","pos")

pop.income.class <- ggplot(data=ClassProps,aes(fill=income,x=year,y=prop)) +
     geom_bar(stat="identity") + 
     geom_text(y=ClassProps$pos,aes(label=paste0(round(100*prop),"%")),size=2) +
     coord_flip() + ggtitle("Distribution of Whole Population by Income Class") +
     xlab("Proportion") + ylab("Year")
pop.income.class











#Graph 5 - Household Size Distribution 
hSizeHist <- ggplot(data=df, aes(x=h_size)) +
     geom_histogram() +
     facet_grid(. ~ year)
hSizeHist

#Graph 6 - Household Size Distribution - Adults Only
hSizeHist <- ggplot(data=df, aes(x=h_num_adults)) +
     geom_histogram(binwidth=1) +
     facet_grid(. ~ year) +
     xlim(0,10)
hSizeHist

hSizeHist <- ggplot(data=df, aes(x=h_num_fams)) +
     geom_histogram(binwidth=1) +
     facet_grid(. ~ year) +
     xlim(0,10)
hSizeHist

demoMeans <- melt(ddply(df, ~ year+seclass, summarise, hsize=mean(h_size),numAdults=mean(h_num_adults),numEarners=mean(h_num_earners),numFamilies=mean(h_num_fams)))
levels(demoMeans$variable) <- c("All Persons","Num. Adults","Num. Workers","Num. Family Units")
demoMeanPlot <- ggplot(data=demoMeans, aes(x=year,y=value,fill=seclass)) +
     geom_bar(stat="identity", position="dodge") +
     facet_grid(. ~ variable) +
     scale_fill_brewer(palette="Set2") +
     xlab("Year") + theme(axis.text.x = element_text(angle=45,hjust=1))+
     ylab("Average") + ggtitle("Household Sizes by Income Class Over Time")
demoMeanPlot

anova(lm(h_num_fams~year,data=subset(df,seclass=="upper",TRUE)))

pairwise.t.test(df$h_num_fams,df$seclass)
