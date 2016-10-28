
library(ggplot2)
library(leaflet)
library(dplyr)
library(tidyr)
library(jsonlite)
library(curl)
library(lubridate)
library(rgdal)



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
    separate(coordinates, into = c("X", "Y"), sep = ",")%>%
    separate(REPORTDATETIME, into = c("Date","Time"), sep="T", remove = FALSE)%>%
    mutate(Weekday = weekdays(as.Date(REPORTDATETIME)),
           Date = as.Date(Date),
           X = as.numeric(gsub("c\\(","",X)),
           Y = as.numeric(gsub("\\)","",Y)))
           
  dc_crime_clean$DATETIME = as.POSIXct(strptime(dc_crime_clean$REPORTDATETIME, tz = "UTC", "%Y-%m-%dT%H:%M:%OSZ"))  
  dchoods <- readOGR("dchoods.kml", "DC neighborhood boundaries")
  
#Shiny server
function(input, output, session) {
    
    filterData <- reactive({
      if (is.null(input$mymap_bounds))
      return(dc_crime_clean)
      bounds <- input$mymap_bounds
      latRng <- range(bounds$north, bounds$south)
      lngRng <- range(bounds$east, bounds$west)
      filter(dc_crime_clean, Y >= latRng[1] & Y <= latRng[2] & X >= lngRng[1] & X <= lngRng[2])
  })

  output$plotOffense <-  
    if(is.null(filterData)){
    return()
    }else{
      renderPlot({
      off <- as.data.frame(table(filterData()$OFFENSE))
      off$Freq <- as.numeric(off$Freq)
      off$Var1 <- factor(off$Var1)
      colnames(off) <- c("OFFENSE","COUNT")
      ggplot(off, aes(x=OFFENSE,y=COUNT)) +
        geom_bar(stat="identity",alpha = 0.45, fill='red') +
        ggtitle("Number of Crimes by Offense") +
        geom_text(aes(label = off$COUNT), size = 3.5, hjust = .58, color = "black")+
        coord_flip()+
        scale_x_discrete(label = function(x) lapply(strwrap(x, width = 10, simplify = FALSE), paste, collapse="\n"))+
        theme(axis.title=element_text(size=10),
              axis.text.y = element_text(size=10, hjust = 1),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.border = element_blank(),
              panel.background = element_blank()
              )
      
    })}

  
  output$plotDayTime <-
    if(is.null(filterData)){
      return()
    }else{
    renderPlot({
      dt <- filterData() %>%
        select(Weekday, SHIFT) %>%
        group_by(Weekday, SHIFT) %>%
        summarize(count = n())
      dt$Weekday <- factor(dt$Weekday, levels= c("Sunday", "Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
      dt$SHIFT <- factor(dt$SHIFT, levels= c("DAY","EVENING","MIDNIGHT"))
      dt[order(dt$Weekday,dt$SHIFT),]
      ggplot(dt,aes(x=SHIFT,y=count,fill=SHIFT)) +
        geom_bar(stat="identity", alpha = 0.75) +
        scale_fill_brewer(palette = 'Set2')+
        scale_y_continuous()+
#        geom_text(aes(label = dt$count))+
        facet_grid(.~Weekday)+
        theme(axis.title=element_text(size=10),
              axis.text.x = element_text(size = 10, angle = 45, hjust = 1),
              panel.background = element_rect(fill = "white"),
              strip.background = element_rect(fill = "white"))
      })}
      
   output$table1 <- 
     renderDataTable(options=list(pageLength=25),{
       filterData()%>%
         select(Weekday, SHIFT, DATETIME, BLOCKSITEADDRESS, OFFENSE, METHOD)
     })
  
   points <- reactive({
     
     cbind(dc_crime_clean$X,dc_crime_clean$Y)
     
   })

   output$mymap <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles("OpenStreetMap.Mapnik",
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points(),
                 popup = paste0("<strong>Report Date: </strong>",
                                dc_crime_clean$DATETIME,
                                "<br><strong>Offense: </strong>", 
                                dc_crime_clean$OFFENSE, 
                                "<br><strong>method: </strong>", 
                                dc_crime_clean$METHOD,
                                "<br><strong>shift: </strong>",
                                dc_crime_clean$SHIFT,
                                "<br><strong>blocksite address: </strong><br>",
                                dc_crime_clean$BLOCKSITEADDRESS
                 ),
                 clusterOptions = markerClusterOptions()
      ) %>%
       addPolygons(data = dchoods, 
                   fillOpacity = 0.2, 
                   color = 'blue',
                   fillColor = 'white',
                   weight = 2.0
                   
                   )
    
  })
}