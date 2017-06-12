#August 29th, 2016 --
# >Make the markers individual by offense --group differently for the second chart 
# > See if any significance in difference in time stamp vars 
# > Add inputSelect for crime. (contingency for all selected > plot generated(no need for OFFENSE plot alone))
# > If crime involved weapon (METHOD) then give stats on that (up or down over last 30 days, etc)
# > add time slider input with vector to make it inclusive.  Set a button to control
# > needed timeframes.
#

library(shiny)
library(shinythemes)
library(leaflet)

fluidPage(#theme = shinytheme("cerulean"),
          tags$head(
          # Include our custom CSS
          includeCSS("style.css")),
          br(),
          navbarPage("Crime DC",id='nav',
            tabPanel("Interactive Map",
                     h3('Documentation for User (scroll down for Shiny App)'),
                     h4('These charts update to reflect data points in the current viewable area of the map. 
                        The Data Explorer tab shows the corresponding rows of the viewable area.'),
                     h5("This Shiny Application creates a leaflet map showing the last 30 days of Crime incidents in Washington, D.C."),
                     h5("data: DC Crime - Last 30 Days [Open Data DC](http://opendata.dc.gov/datasets)"),
                     h4("1st Step: Load needed libraries."),
                     h5("+ `dplyr` for distinct(), select(), and mutate() functions."),
                     h5("+ `tidyr` for the separate() function."),
                     h5("+ `jsonlite` for the fromJSON() function needed to retrieve our dataset via the GeoJSON api."),
                     h5("+ `lubridate` for ymd_hms() function to clean datetime column."),
                     h5("+ `leaflet` to create our map."),
                     br(),
                     h4("2nd Step: Create Mappable Dataframe"),
                     h5("Our data comes in a `GeoJSON` format. "),
                     h5("The `jsonlite::fromJSON()` function retrieves the from the collection format it exists in and stores it in list format in the variable defined `dccrimejsonlite`."),
                     h5("Using the `cbind` function, we combine these two lists into a dataframe defined as `dc_crime_json`.  Our next step is to clean the data and return a usable dataframe."),
                     h5("We access the list elements which are nested within the `features` level, and then combine these two large lists:"),
                     h5("- `properties` list which contain the main table elements for the dataset. "),
                     h5("- `geometry` list which contains the **latitude** and **longitude** columns which we will need to map the data. "),
                     br(),
                     h4("3rd Step: Render the Map"),
                     h5("First, we define a `points` element with the latitude and longitude vectors corresponding to the dataframe. This is used to pass the Latitude and Longitude columns to the leaflet map: see below where `addMarkers(data = points ...`."),
                     h5("Rendering a map with leaflet is as easy as calling the `leaflet()` function.  Using chain operation, we simply add elements to our map after calling it."),
                     br(),
                     hr(),
                     br(),
                     h4("Using the Shiny App"),
                     h5("note: the option for `clusterOptions` is set equal to `markerClusterOptions()` enabling leaflet's clustering of map points."),
                     h5("In order to expand clusters, you can zoom in or click on the cluster to expand the viewable area.  The summary charts will always update in order to reflect the data in the viewable area of the map."),
                     h5("Click the data explorer tab in order to see summary rows of the viewable map area incident points."),
                     
                     fluidRow(column(7,leafletOutput("mymap", width = '100%', height = '400px')),
                              column(5,plotOutput("plotDayTime"))),
                     
                     
                     fluidRow(
                              column(4,plotOutput("plotOffense")),
                              column(4,plotOutput("plotTimeline")),
                              column(4,plotOutput("plotSeries"))
                              ),
                     br(),
                     absolutePanel(id = "controls",class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                   top = 350, left = "auto", right = 50, bottom = "auto",
                                   width = 220, height = "auto", style = "opacity: .65",
                                           
                                   h4("Crime DC - Last 30 Days"), br(), 
                                   h5("This Panel is Draggable.."),
                                   actionButton("resetMap", "Reset Map", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                   br(),
                                   paste("Click on cluster or scroll to zoom-in, Click an individual marker for additional detail popup.")
                    )
                    
          ),
          tabPanel("Data Explorer",
                   dataTableOutput("table1"))
                   
          # ),
          # tabPanel("Documentation",
          #          includeHTML("readme.html"))
        ),
        a("data source: http://opendata.dc.gov/datasets",href="http://opendata.dc.gov/datasets"),
        paste(' | '),
        a("direct data source api link:",href='http://opendata.dc.gov/datasets/dc3289eab3d2400ea49c154863312434_8.geojson'),
        paste(' | '),
        a("author: neil kutty", href="http:/twitter.com/neilkutty"),
        paste(' | '),
        a("github",href="https://github.com/sampsonsimpson/DC_Crime_Data"),
        paste(' | '),
        a("neighborhood boundaries KML file",href="https://www.google.com/maps/d/viewer?mid=1z_3yTY-G8hZZ3z5qh3tM9dBh5ps&hl=en_US")

        
)
