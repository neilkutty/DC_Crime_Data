library(rgdal)

dchoods <- readOGR("dchoods.kml", "DC neighborhood boundaries")



output$plotDay <-  
  renderPlot({
    day <- as.data.frame(table(filterData()$Weekday))
    day$Freq <- as.numeric(day$Freq)
    colnames(day) <- c("Weekday","COUNT")
    day$Weekday <- factor(day$Weekday, levels= c("Sunday", "Monday", 
                                                 "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
    day[order(day$Weekday),]
    ggplot(day, aes(x=Weekday,y=COUNT)) +
      geom_bar(stat="identity",alpha = 0.3,color = 'blue', fill='blue') +
      ggtitle("Number of Crimes by Day of Week") +
      geom_text(aes(label = day$COUNT), size = 5.5, hjust = .77, color = "black")+
      theme(axis.title=element_text(size=10),
            axis.text.x = element_text(face = 'bold', size=10, angle = 45, hjust = 1)
      )
    
  })

output$plotDayTime <-
  renderPlot({
    dt <- filterData() %>%
      select(Weekday, SHIFT) %>%
      summarize(count = n())
    
    dt$Weekday <- factor(dt$Weekday, levels= c("Sunday", "Monday", 
                                               "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
    dt[order(dt$Weekday),]
    ggplot(dt,aes(x=Weekday,y=count)) +
      geom_bar(stat="identity", alpha = 0.3, color='blue', fill='blue') +
      facet_grid(.~SHIFT)
      
      
             
    
  })

dt <- dc_crime_clean %>%
  select(Weekday, SHIFT) %>%
  summarize(count = n())

dt$Weekday <- factor(dt$Weekday, levels= c("Sunday", "Monday", 
                                           "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
dt[order(dt$Weekday),]
ggplot(dt,aes(x=Weekday,y=count)) +
  geom_bar(stat="identity", alpha = 0.3, color='blue', fill='blue') +
  facet_grid(.~SHIFT)