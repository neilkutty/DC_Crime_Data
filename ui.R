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
           includeCSS("style.css")
           
          ),
          br(),
          navbarPage("Crime DC",id='nav',
            tabPanel("Interactive Map",
                     h5('These charts update to reflect data points in the current viewable area of the map. 
                        The Data Explorer tab shows the corresponding rows of the viewable area.'),
                     
                     fluidRow(column(7,leafletOutput("mymap", width = '100%', height = '400px')),
                              column(5,plotOutput("plotDayTime"))),
                     
                     
                     fluidRow(
                              column(4,plotOutput("plotOffense")),
                              column(4,plotOutput("plotTimeline")),
                              column(4,plotOutput("plotSeries"))
                              ),
                     br(),
                     absolutePanel(id = "controls",class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                   top = 225, left = 50, right = "auto", bottom = "auto",
                                   width = 150, height = "auto", style = "opacity: .65",
                                           
                                   h3("Crime DC - Last 30 Days"), br(), 
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
