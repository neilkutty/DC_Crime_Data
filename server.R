
library(ggplot2)
library(leaflet)
library(dplyr)
library(tidyr)
library(jsonlite)
library(curl)


########---------------------------------------------------------------------#>>>
  ## Retrieve the data in JSON format from opendata.dc.gov using fromJson()
  dccrimejsonlite <- fromJSON('http://opendata.dc.gov/datasets/dc3289eab3d2400ea49c154863312434_8.geojson')
  ## use cbind() combine the list elements and create a dataframe
  dc_crime_json <- cbind(dccrimejsonlite$features$properties,dccrimejsonlite$features$geometry)
  
  ## Get distinct Offenses for shiny input
  offenses <- distinct(select(dc_crime_json,OFFENSE))
  row.names(offenses) <- offenses$OFFENSE
  
  ## Seperate and clean lat/long columns but keep original datetime column
  ## --also separate REPORTDATETIME column
  dc_crime_clean <- dc_crime_json %>% 
    separate(coordinates, into = c("X", "Y"), sep = ",", remove = FALSE)%>%
    separate(REPORTDATETIME, into = c("Date","Time"), sep="T", remove = FALSE)%>%
    mutate(Weekday = weekdays(as.Date(REPORTDATETIME)))
  
  ## convert lat and long columns to numbers and remove non numeric characters
  dc_crime_clean$X <- as.numeric(gsub("c\\(","",dc_crime_clean$X))
  dc_crime_clean$Y <- as.numeric(gsub("\\)","",dc_crime_clean$Y))
  
  #Create date column from datetime
  dc_crime_clean$DateClean <- as.Date(dc_crime_clean$Date)
########---------------------------------------------------------------------#>>>
#get summary stats



function(input, output, session) {
  
  
    filterData <- reactive({
    if (is.null(input$mymap_bounds))
      return(dc_crime_clean)
    bounds <- input$mymap_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    filter(dc_crime_clean,
           Y >= latRng[1] & Y <= latRng[2] & X >= lngRng[1] & X <= lngRng[2])
  })
  
  output$plotOffense <-  
    renderPlot({
      off <- as.data.frame(table(filterData()$OFFENSE))
      off$Freq <- as.numeric(off$Freq)
      off$Var1 <- reorder(off$Var1,-off$Freq)
      colnames(off) <- c("OFFENSE","COUNT")
      ggplot(off, aes(x=OFFENSE,y=COUNT)) +
        geom_bar(stat="identity",alpha = 0.3,color='red',fill='red') +
        ggtitle("Number of Crimes by Offense") +
        geom_text(aes(label = off$COUNT), size = 5.5, hjust = .77, color = "black")+
        theme(axis.title=element_text(size=10),
              axis.text.x = element_text(face = 'bold', size=10, angle = 45, hjust = 1)
              )
      
    })
  
  output$plotDay <-  
    renderPlot({
      day <- as.data.frame(table(filterData()$Weekday))
      day$Freq <- as.numeric(day$Freq)
      day$Var1 <- reorder(day$Var1,-day$Freq)
      colnames(day) <- c("Weekday","COUNT")
      ggplot(day, aes(x=Weekday,y=COUNT)) +
        geom_bar(stat="identity",alpha = 0.3,color='blue',fill='blue') +
        ggtitle("Number of Crimes by Day of Week") +
        geom_text(aes(label = day$COUNT), size = 5.5, hjust = .77, color = "black")+
        theme(axis.title=element_text(size=10),
              axis.text.x = element_text(face = 'bold', size=10, angle = 45, hjust = 1)
        )
      
    })
  
   output$table1 <- 
     renderDataTable(options=list(pageLength=15),{
       filterData()%>%
         select(Weekday, SHIFT, Date, Time, BLOCKSITEADDRESS, OFFENSE, METHOD, OBJECTID)
     })
  
  points <- eventReactive(input$reset, {
    
    cbind(dc_crime_clean$X,dc_crime_clean$Y)
    
    }, ignoreNULL = FALSE)
  

   output$mymap <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles("OpenStreetMap.Mapnik",
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points(),
                 popup = paste0("<strong>Report Date: </strong>",
                                dc_crime_clean$DateClean,
                                "<br><strong>Offense: </strong>", 
                                dc_crime_clean$OFFENSE, 
                                "<br><strong>method: </strong>", 
                                dc_crime_clean$METHOD,
                                "<br><strong>shift:</strong>",
                                dc_crime_clean$SHIFT,
                                "<br><strong>blocksite address:</strong><br>",
                                dc_crime_clean$BLOCKSITEADDRESS
                 ),
                 clusterOptions = markerClusterOptions()
      ) 
    
  })
}