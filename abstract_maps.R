#############################################################################################################################################
# PACKAGES
#############################################################################################################################################
 
require(leaflet)
require(shinythemes)
require(rgdal)
require(maptools)
require(rmapshaper)
require(shiny)
require(leaflet.extras)
 
#############################################################################################################################################
# UI
#############################################################################################################################################
 
shinyUI(
bootstrapPage(theme = shinytheme("united"),
 navbarPage(title="Where to live in Hamburg?",
 tabPanel("Karte",
 div(class="outer",
 
tags$style(type = "text/css", ".outer {position: fixed; top: 50px; left: 0; right: 0; bottom: 0; overflow: hidden; padding: 0}"),
 
leafletOutput("mymap", width = "100%", height = "100%")
)))))
 
#############################################################################################################################################
# SERVER
#############################################################################################################################################
 
shinyServer(
function(input, output, session) {
 
# setwd
setwd("YourPath")
 
# load your own shapes
hhshape <- readOGR(dsn = ".", layer = "click2shp_out_poly")
 
# load some data (could be anything)
data <- read.csv("anwohner.csv", sep = ";", header = T)
rownames(data) <- data$ID
hhshape <- SpatialPolygonsDataFrame(hhshape, data)
 
# remove rivers from sp file
hhshape <- hhshape[!(hhshape$Stadtteil %in% c("Alster","Elbe","Nix")), ]
 
# create a continuous palette function
pal <- colorNumeric(
 palette = "Blues",
 domain = hhshape@data$Anwohner
)
 
# plot map
output$mymap <- renderLeaflet({ leaflet(options = leafletOptions(zoomControl = FALSE, minZoom = 11, maxZoom = 11, dragging = FALSE)) %>%
 setView(lng = 9.992924, lat = 53.55100, zoom = 11) %>%
 addPolygons(data = hhshape,
  fillColor = ~pal(hhshape@data$Anwohner), fillOpacity = 1, stroke = T, color = "white", opacity = 1, weight = 1.2, layerId = hhshape@data$ID,
  highlightOptions = highlightOptions(color= "grey", opacity = 1, fillColor = "grey", stroke = T, weight = 12, bringToFront = T, sendToBack = TRUE),
  label=~stringr::str_c(Stadtteil,' ',"Anwohner:",formatC(Sicherheit, big.mark = ',', format='d')),
  labelOptions= labelOptions(direction = 'auto'))
})
})
