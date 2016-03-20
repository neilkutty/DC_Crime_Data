library(rgdal)
library(ggplot2)
library(maptools)
library(dplyr)
library(ggmap)
library(leaflet)
library(dplyr)
library(curl)

# jsonlite
## AUTOMATION OF DC Crime Last 30 Days Data
########---------------------------------------------------------------------#>>>
library(jsonlite)
dccrimejsonlite <- fromJSON('http://opendata.dc.gov/datasets/dc3289eab3d2400ea49c154863312434_8.geojson')
dc_crime_json <- cbind(dccrimejsonlite$features$properties,dccrimejsonlite$features$geometry)

## Get distinct Offenses for shiny input
offenses <- distinct(select(dc_crime_json,OFFENSE))
row.names(offenses) <- offenses$OFFENSE

##  Seperate and clean lat/long columns
library(tidyr)
dc_crime_clean <- dc_crime_json %>% 
  separate(coordinates, into = c("X", "Y"), sep = ",") 

dc_crime_clean$X <- as.numeric(gsub("c\\(","",dc_crime_clean$X))
dc_crime_clean$Y <- as.numeric(gsub("\\)","",dc_crime_clean$Y))

########---------------------------------------------------------------------#>>>



function(input, output, session) {


  
  points <- eventReactive(input$reset, {
    
    cbind(dc_crime_clean$X,dc_crime_clean$Y)
    
    }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    
    leaflet() %>%
      addProviderTiles("OpenStreetMap.Mapnik",
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points(),popup = paste0("<strong>Report Datetime: </strong>",
                                                dc_crime_json$REPORTDATETIME,
                                                "<br><strong>Offense: </strong>", 
                                                dc_crime_json$OFFENSE, 
                                                "<br><strong>method: </strong>", 
                                                dc_crime_json$METHOD,
                                                "<br><strong>shift:</strong>",
                                                dc_crime_json$SHIFT,
                                                "<br><strong>blocksite address:</strong><br>",
                                                dc_crime_json$BLOCKSITEADDRESS
                                                ),
                 
                 clusterOptions = markerClusterOptions()
                   
                 ) 
    
  })
 
  }