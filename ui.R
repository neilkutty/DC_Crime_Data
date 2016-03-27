library(rgdal)
library(ggplot2)
library(maptools)
library(dplyr)
library(ggmap)
library(leaflet)
library(dplyr)
library(jsonlite)
library(tidyr)

fluidPage(
  titlePanel("DC Crime - Last 30 Days"),
  h3("Map Explorer for last 30 days DC Crime Dataset"),
  
  helpText("Data May be Delayed"),
  p(
    class="text-info",
    a("data source: http://opendata.dc.gov/datasets",href="http://opendata.dc.gov/datasets"),
    br(),
   paste("GeoJSON API url: http://opendata.dc.gov/datasets/dc3289eab3d2400ea49c154863312434_8.geojson"),
    br()
   ),
  p(
    class="text-muted",
    paste("If disconnected from server, try reloading... map is in dev with new features to be added. \n suggestions and evolutions are welcome:"),
    a("github",href="https://github.com/sampsonsimpson/DC_Crime_Data")
  ),
  p(
    class="text-primary",
    a("author: neil kutty", href="http:/twitter.com/neilkutty"),
    br(),
    a("original ui and server code", href="https://rstudio.github.io/leaflet/shiny.html")
  ),
  
  p(
    class="text-info",
    paste("Click on cluster or scroll for zoom. Click on individual marker for additional detail popup.")
  ),

  
  leafletOutput("mymap"),
  br(),
 
  
  actionButton("reset","Reset Map View")
  
 
)