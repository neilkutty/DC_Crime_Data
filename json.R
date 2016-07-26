# jsonlite
## AUTOMATION OF DC Crime Last 30 Days Data
########---------------------------------------------------------------------#>>>
json <- function() {
  ## Retrieve the data in JSON format from opendata.dc.gov using fromJson()
  dccrimejsonlite <- fromJSON('http://opendata.dc.gov/datasets/dc3289eab3d2400ea49c154863312434_8.geojson')
  ## use cbind() to access the list elements and create dataframe
  dc_crime_json <- cbind(dccrimejsonlite$features$properties,dccrimejsonlite$features$geometry)
  
  ## Get distinct Offenses for shiny input
  offenses <- distinct(select(dc_crime_json,OFFENSE))
  row.names(offenses) <- offenses$OFFENSE
  
  ## Seperate and clean lat/long columns
  ## --also separate REPORTDATETIME column
  dc_crime_clean <- dc_crime_json %>% 
    separate(coordinates, into = c("X", "Y"), sep = ",")%>%
    separate(REPORTDATETIME, into = c("Date","Time"), sep="T")
  
  ## convert lat and long columns to numbers and remove non numeric characters
  dc_crime_clean$X <- as.numeric(gsub("c\\(","",dc_crime_clean$X))
  dc_crime_clean$Y <- as.numeric(gsub("\\)","",dc_crime_clean$Y))
  
  #Create date column from datetime
  dc_crime_clean$DateClean <- as.Date(dc_crime_clean$Date)
  bydate <- group_by(dc_crime_clean,DateClean,OFFENSE,SHIFT)
  crimedc_bydate <- summarise(bydate,
                              count=n())
  
}