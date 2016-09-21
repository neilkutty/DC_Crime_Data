# Garbage Code
rm(list = ls())

count(names(dc_crime_clean))
names(dc_crime_clean)

sapply(names(dc_crime_clean), table)


x<-sapply(dc_crime_clean, table)


list2env(x,envir=.GlobalEnv)

n <- sapply(dc_crime_clean, unique)

j <- sapply(n,length)
j <- sort(j,decreasing=FASLE)

jdat <- as.data.frame(j)


library(dplyr)
library(ggplot2)

ts <- dc_crime_clean %>%
  select(DateClean) %>%
  group_by(DateClean) %>%
  summarize(Count = n())

timeplot <- ggplot(ts, aes(x=DateClean,y=Count))+
  geom_line()+
  geom_smooth()+
  geom_text(aes(label = ts$Count),color='black')

plot(timeplot)
