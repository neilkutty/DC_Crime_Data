---
title: "Mapping DC Crime with R and Leaflet"
author: "Neil Kutty"
date: "April 3, 2016"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Getting and cleaning the data
For my first blog post in a *long* time, I thought I would write a how-to on creating a simple leaflet map in R with with open data from opendata.dc.gov

Finding open data that is updated, recent, and easily accessible on the web has become easier with the recent strides in making data more accessible to everyone (see: opportunity.census.gov) and developers in particular (see: catalog.data.gov).  

Wanting to keep this post lightweight, map-centric, and regionally relevant, I am using a local dataset for the last 30 days of crime in Washington, D.C.

The dataset is available in downloadable or GeoJSON format. I'm going with JSON so that the shiny app can be standalone without additional need for data management.  

Several libraries are required for this project. use the `install.packages('packagename')` command to install the libraries/packages before attempting the code to load them below

```{r libraries,eval=FALSE}

library(rgdal)
library(ggplot2)
library(maptools)
library(dplyr)
library(ggmap)
library(leaflet)
library(dplyr)
library(jsonlite)
library(tidyr)
library(curl)
```

Retrieval of the data is bit *chunky* at the moment, utilizing the ```jsonlite``` library and some cleanup code we create a usable dataset below: 

```{r json,eval=FALSE}
## Retrieve the data in JSON format from opendata.dc.gov using fromJson()
dccrimejsonlite <- fromJSON('http://opendata.dc.gov/datasets/dc3289eab3d2400ea49c154863312434_8.geojson')
## use cbind() to access the list elements and create dataframe
dc_crime_json <- cbind(dccrimejsonlite$features$properties,dccrimejsonlite$features$geometry)

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
```

In the above, the data is retrieved using the ```fromJSON()``` function, and the columns are retrieved using the ```cbind()``` function. 

The latitude and longitude columns are cleaned using the ```separate()``` function from library ```tidyr``` and RegEx to remove erroneous characters from the columns.

-- in dev... 