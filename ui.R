library(shiny)
library(shinythemes)
library(leaflet)

fluidPage(#theme = shinytheme("cerulean"),
          tags$head(
            # Include our custom CSS
            includeCSS("style.css")
           
          ),
          navbarPage("crimeDC",id='nav',
            tabPanel("Interactive Map",
                              titlePanel("DC Crime - Last 30 Days"),
                              helpText("Click on cluster or scroll to zoom-in, Click an individual marker for additional detail popup."),
                            p(
                                class="text-info",
                                a("data source: http://opendata.dc.gov/datasets",href="http://opendata.dc.gov/datasets"),
                                br(),
                                a("author: neil kutty", href="http:/twitter.com/neilkutty"),
                                a("github",href="https://github.com/sampsonsimpson/DC_Crime_Data")
                              ),
                              
                        
                              actionButton("reset","Reset Map View"),
                              br(),
                              
                              leafletOutput("mymap", width = '100%', height = '750px'),
                              
                              
                              br(),
                              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                            draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                            width = 500, height = "auto",
                                            plotOutput("plot1",height=300),
                                            style = "opacity: .75")
          ),
          tabPanel("Data Explorer",
                   dataTableOutput("table1")
                   
          )
        )
            
  
)
