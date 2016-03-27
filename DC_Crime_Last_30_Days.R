library(rgdal)
library(ggplot2)
library(maptools)
library(dplyr)
library(ggmap)
library(leaflet)
#DC Crime Data

crimesdc <- read.csv("Crime_Incidents__Last_30_Days.csv", header=TRUE)
dcmap <- readShapeSpatial("district_of_columbia_highway.shp")


ggplot() +  geom_point(data=crimesdc, aes(x=X, y=Y), color="red")

dc <- get_map(location="Washington D.C.",zoom=12)
ggmap(dc)+geom_point(data=crimesdc,alpha=1/4,aes(x=X,y=Y,color=OFFENSE))+scale_color_discrete()

# xml2
library(xml2)

# jsonlite
## AUTOMATION OF DC Crime Last 30 Days Data
########---------------------------------------------------------------------#>>>
library(jsonlite)
dccrimejsonlite <- fromJSON('http://opendata.dc.gov/datasets/dc3289eab3d2400ea49c154863312434_8.geojson')
dc_crime_json <- dccrimejsonlite$features$properties
dc_crime_json$BLOCKXCOORD <- dc_crime_json$BLOCKXCOORD/10000
dc_crime_json$BLOCKYCOORD <- dc_crime_json$BLOCKYCOORD/10000

########---------------------------------------------------------------------#>>>

#perform summarisations and grouping
#



