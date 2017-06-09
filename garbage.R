
#Train Model
########---------------------------------------------------------------------#>>>
## Retrieve the data in JSON format from opendata.dc.gov using fromJson()
dccrimejsonlite <- fromJSON('http://opendata.dc.gov/datasets/dc3289eab3d2400ea49c154863312434_8.geojson')
## use cbind() combine the list elements and create a dataframe
dc_crime_json <- cbind(dccrimejsonlite$features$properties,dccrimejsonlite$features$geometry)


## Seperate and clean lat/long columns but keep original datetime column
## --also separate REPORT_DAT column
dc_crime_lite <- dc_crime_json %>% 
  select(OFFENSE,SHIFT,REPORT_DAT,BLOCK,METHOD,coordinates) %>%
  separate(coordinates, into = c("X", "Y"), sep = ",")%>%
  separate(REPORT_DAT, into = c("Date","Time"), sep="T", remove = FALSE)%>%
  mutate(Weekday = weekdays(as.Date(REPORT_DAT)),
         Date = as.Date(Date),
         X = as.numeric(gsub("c\\(","",X)),
         Y = as.numeric(gsub("\\)","",Y)))

dc_crime_lite$DATETIME = as.POSIXct(strptime(dc_crime_lite$REPORT_DAT, tz = "UTC", "%Y-%m-%dT%H:%M:%OSZ"))  

dchoods <- readOGR("dchoods.kml", "DC neighborhood boundaries")


dcCrimeML <- dc_crime_lite
dcCrimeML[] <- sapply(dc_crime_lite, function(x) as.numeric(as.factor(x)))
tr <- createDataPartition(dcCrimeML$Weekday, p=0.7, list = F)
train <- dcCrimeML[tr,]
test <- dcCrimeML[-tr,]
model_glm <- train(Weekday ~ ., data = train, method="glm")
glm_results <- predict(model_glm, test)
glm_results$overall[1]


#---------------------------------------------------------------------------------####

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

scat <- dc_crime_clean %>%
  select(OFFENSE, DATETIME) %>%
  group_by(OFFENSE, DATETIME) %>%
  summarize(count = n())

dt <- dc_crime_clean %>%
  select(Weekday, SHIFT) %>%
  group_by(Weekday, SHIFT) %>%
  summarize(count = n())

dt$Weekday <- factor(dt$Weekday, levels= c("Sunday", "Monday", 
                                           "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
dt[order(dt$Weekday),]
ggplot(dt,aes(x=Weekday,y=count)) +
  geom_bar(stat="identity", alpha = 0.3, color='blue', fill='blue') +
  facet_grid(.~SHIFT)

#-------

scat <- dc_crime_clean %>%
  select(OFFENSE, Date) %>%
  group_by(OFFENSE, Date) %>%
  summarize(count = n())

ggplot(scat, aes(x=Date, y=count, color=OFFENSE))+
  geom_point()+
  ggtitle("Number of Crimes by Day by Offense")+
theme(axis.title=element_text(size=10),
      axis.text.x = element_text(size = 10, angle = 45, hjust = 1),
      panel.background = element_rect(fill = "white"),
      strip.background = element_rect(fill = "white"),
      legend.position = c(1,1))

ts <- dc_crime_clean %>%
  select(Date) %>%
  group_by(Date) %>%
  summarize(count = n())
