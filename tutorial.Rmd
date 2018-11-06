---
title: "Drawing Interactive Maps in R"
author: "Xinyuan Cao (xc2461)"
output:
  html_document:
    df_print: paged
    toc: yes
  html_notebook:
    toc: yes
    toc_float: yes
editor_options:
  chunk_output_type: console
---


While static and maps can enliven geographic data, interactive maps can take them to a new level. Interactivity can have many different functions and forms. We can pan around and zoom into any part of a geographic dataset overlaid on a map to show the context. We can also tilt and rotate maps freely to have a better view. The release of the leaflet package in 2015 revolutionized interactive web map creation from within R and a number of packages have built on these foundations adding new features (e.g. leaflet.extras) and making the creation of web maps as simple as creating static maps. Here we'll introduce two packages `leaflet` and `plotly` in drawing maps so as to provide powerful tools when we need to interactively processing geo-data.




# Plotting with `leaflet`
Leaflet is one of the most popular open-source JavaScript libraries for interactive maps. The JavaScript library actively developed at [github.com/Leaflet/Leaflet](github.com/Leaflet/Leaflet).

The leaflet package creates interactive web maps in few lines of code. One of the exciting things about the package is its tight integration with the R package for interactive on-line visualisation, shiny. Here we have a quick start for those who want to draw maps in an interactive way with package `leaflet`.

For more information on `rstudio/leaflet`, see [rstudio.github.io/leaflet/](rstudio.github.io/leaflet/).

## Installation

To install this R package, run this command at your R prompt:
```{r cache=TRUE}
devtools::install_github("rstudio/leaflet")
# or you can directly use
# install.packages("leaflet")
```

## Basic Usage
### A simple Example
There are four steps to create a Leaflet map:

1. Create a map widget by calling leaflet().
2. Add layers (i.e., features) to the map by using layer functions (e.g. addTiles, addMarkers,  addPolygons) to modify the map widget.
3. Repeat step 2 as desired.
4. Print the map widget to display it.

```{r}
library(leaflet)

ex1 <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng = -73.9626, lat = 40.8075, popup = "Columbia University")
ex1  # Print the map
```


### Map Methods

There are several ways to manipulate the attributes of the map widget. Please see the help page ?setView for details.

+ `setView()` sets the center of the map view and the zoom level;
+ `fitBounds()` fits the view into the rectangle [lng1, lat1] – [lng2, lat2];
+ `clearBounds()` clears the bound, so that the view will be automatically determined by the range of latitude/longitude data in the map layers if provided;

```{r}
ex2 <- leaflet() %>%
  addTiles() %>%
  setView(lng = -73.9626, lat = 40.8075, zoom = 9) # set the zoom view = 9
ex2
```

### Data Object


* From base R:
    + lng/lat matrix
    + data frame with lng/lat columns

* From the [sp package](https://cran.rstudio.com/web/packages/sp/index.html):
    + SpatialPoints[DataFrame]
    + Line/Lines
    + SpatialLines[DataFrame]
    + Polygon/Polygons
    + SpatialPolygons[DataFrame]

* From the [maps package](https://cran.rstudio.com/web/packages/maps/index.html):
    + the data frame from returned from map()


## Other Features
### Third-Party Tiles

Many popular free third-party basemaps can be added using the `addProviderTiles()` function, which is implemented using the [leaflet-providers plugin](https://github.com/leaflet-extras/leaflet-providers). See [here](http://leaflet-extras.github.io/leaflet-providers/preview/index.html) for the complete set.

```{r}
ex3 <- ex1 %>% addProviderTiles(providers$Stamen.Toner)
ex3
```

You can also use `addWMSTiles()` to add WMS (Web Map Service) tiles. The map below shows the Base Reflectivity (a measure of the intensity of precipitation occurring) using the WMS from the Iowa Environmental Mesonet:

```{r}
ex4 <- leaflet() %>%
  addTiles() %>%
  setView(-93.65, 42.0285, zoom = 4) %>%
  addWMSTiles(
    "http://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r.cgi",
    layers = "nexrad-n0r-900913",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    attribution = "Weather data © 2012 IEM Nexrad"
  )
ex4
```

If you need more than one basemap on a map, feel free to stack them by adding multiple tile layers. This generally only makes sense if the front tiles consist of semi transparent tiles, or have an adjusted opacity via the `options` argument.

```{r}
ex5 <- ex1 %>% addProviderTiles(providers$MtbMap) %>%
  addProviderTiles(providers$Stamen.TonerLines,
    options = providerTileOptions(opacity = 0.35)) %>%
  addProviderTiles(providers$Stamen.TonerLabels)
ex5
```




### Markers

We can add icon markers to locate some particular places. Here we want to mark all of the subway stations in NYC, with popup as the station names.

Here, to have a better view of the where the area we are looking at is, we use `addMiniMap` to have a mini-map in the corner. And the square inside shows the showing part of the big map is in what part of the whole country.

```{r}
subway.df <- read.csv("SUBWAY_STATION.csv")
print(subway.df[c(1: 5), ]) # show the data of nyc subway stations

ex6 <- leaflet(subway.df) %>%
  addTiles() %>%
  addMarkers(~x, ~y, popup = ~as.character(NAME)) %>%
  setView(lng = -73.9626,lat = 40.8075,zoom = 14) %>% # set the zoom view = 14
  addMiniMap()
ex6
```

For various purposes we can also customize their color, radius, stroke, opacity, etc. Leaflet supports even more customizable markers using the [awesome markers](https://github.com/lvoogdt/Leaflet.awesome-markers) leaflet plugin. We can also use circle markers.



```{r}
ex7 <- leaflet(subway.df) %>%
  addTiles() %>%
  addCircleMarkers(~x, ~y, popup = ~as.character(NAME)) %>%
  setView(lng = -73.9626,lat = 40.8075,zoom = 12) # set the zoom view = 12
ex7
```

### Popups & Labels
Popups are small boxes containing arbitrary HTML, that point to a specific point on the map. Here we show an example of Columbia University.

```{r}
content <- paste(sep = "<br/>",
  "<b><a href='https://www.columbia.edu'> Columbia University</a></b>",
  "116th and Broadway",
  "New York, NY 10027"
)

ex8 <- leaflet() %>% 
  addTiles() %>%
  addPopups(-73.9626, 40.8075, content,
    options = popupOptions(closeButton = FALSE)
  )
ex8

```


A label is a textual or HTML content that can attached to markers and shapes to be always displayed or displayed on mouse over. Unlike popups you don’t need to click a marker/polygon for the label to be shown.

```{r}
ex9 <- leaflet() %>% 
  addTiles() %>%
  addMarkers(-73.9626, 40.8075, label = "Columbia University")
ex9
```


### Lines & Shapes

Line and polygon data can come from a variety of sources:

- `SpatialPolygons`, `SpatialPolygonsDataFrame`, `Polygons`, and `Polygon` objects (from the `sp` package)
- `SpatialLines`, `SpatialLinesDataFrame`, `Lines`, and `Line` objects (from the `sp` package)
- `MULTIPOLYGON`, `POLYGON`, `MULTILINESTRING`, and `LINESTRING` objects (from the `sf` package)
- `map` objects (from the `maps` package’s `map()` function); use `map(fill = TRUE)` for polygons, `FALSE` for polylines
- Two-column numeric matrix; the first column is longitude and the second is latitude. Polygons are separated by rows of `(NA, NA)`. It is not possible to represent multi-polygons nor polygons with holes using this method; use `SpatialPolygons` instead.

I'll use the census data, and filter those states in the east coast. Here we add a polygons in the border of each state. Also we add a highlighting shapes to emphasize the currently moused-over polygon. We can also use other commands `addCircles()`, `addRectangles()` to add shapes.

For legend, usually we use the `addLegend` function to add a legend. The easiest way to use `addLegend` is to provide `pal` (a palette function, as generated from `colorNumeric` et al.) and `values`, and let it calculate the colors and labels for you.

```{r}
library(sp)
library(tidyverse)
library(raster)
library(rgdal)
# From https://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
states <- readOGR("cb_2017_us_state_20m/cb_2017_us_state_20m.shp",
  layer = "cb_2017_us_state_20m", GDAL1_integer64_policy = TRUE)

neStates <- subset(states, states$STUSPS %in% c(
  "ME", "VT", "NH", "MA", "RI", "CT", "NY", "NJ", "FL", 
  "PA", "DE", "MD", "WV", "VA", "NC", "SC", "GA", "AL"
)) # choose the states in the east coast

palette <- leaflet::colorBin("YlOrRd", domain = neStates$ALAND)

ex10 <-leaflet(neStates) %>%
  addTiles() %>%
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
  opacity = 1.0, fillOpacity = 0.5,
  fillColor = ~palette(ALAND),
  highlightOptions = highlightOptions(color = "white", weight = 2,
  bringToFront = TRUE)) %>%
  addLegend(pal = palette, values = ~ALAND, position="bottomright",
            title = "US Census (East Coast)") 
ex10
```





# Plotting with `plotly`
## Installation

```{r}
devtools::install_github("ropensci/plotly")
# or you can directly use
# install.packages("plotly")
# Plotly is now on CRAN!
```




Reference:

1. https://cran.r-project.org/doc/contrib/intro-spatial-rl.pdf
2. http://rstudio.github.io/leaflet/
3. https://geocompr.robinlovelace.net/adv-map.html#interactive-maps
4. https://plot.ly/r/maps/



