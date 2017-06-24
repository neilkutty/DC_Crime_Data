
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
                   
                     
                     fluidRow(column(7,leafletOutput("mymap", width = '100%', height = '400px')),
                              column(5,plotOutput("plotDayTime"))),
                     
                     
                     fluidRow(
                              column(4,plotOutput("plotOffense")),
                              column(4,plotOutput("plotTimeline")),
                              column(4,plotOutput("plotSeries"))
                              ),
                     br(),
                     absolutePanel(id = "controls",class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                   top = 150, left = "auto", right = 50, bottom = "auto",
                                   width = 220, height = "auto", style = "opacity: .78",
                                           
                                   h4("Crime DC - Last 30 Days"), br(), 
                                   h4("This Panel is Draggable.."),
                                   actionButton("resetMap", "Reset Map", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                   br(),
                                   paste("Click on cluster or scroll to zoom-in, Click an individual marker for additional detail popup.")
                    )
                    
          ),
          tabPanel("Data Explorer",
                   dataTableOutput("table1")),
                   
         
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

