#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
###############################Install Related Packages #######################
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
if (!require("shiny")) {
    install.packages("shiny")
    library(shiny)
}
if (!require("leaflet")) {
    install.packages("leaflet")
    library(leaflet)
}
if (!require("leaflet.extras")) {
    install.packages("leaflet.extras")
    library(leaflet.extras)
}
if (!require("dplyr")) {
    install.packages("dplyr")
    library(dplyr)
}
if (!require("magrittr")) {
    install.packages("magrittr")
    library(magrittr)
}
if (!require("mapview")) {
    install.packages("mapview")
    library(mapview)
}
if (!require("leafsync")) {
    install.packages("leafsync")
    library(leafsync)
}
if (!require("geojsonio")) {
    install.packages("geojsonio")
    library(geojsonio)
}


# df.arrest.proc <- read.csv("../processed/nyc_arrest_processed.csv")
nyc.districts.proc <- geojson_read("../processed/nyc_community_districts_processed.geojson",
                                   what="sp")
shinyServer(
function(input, output) {
#     ####################### Tab 2 Map ##################
    
    # inferno
    pal <- colorNumeric("RdYlBu", NULL)
    
    map_base <- leaflet(nyc.districts.proc,options = leafletOptions(minZoom = 10, maxZoom = 13)) %>%
        setView(-73.9834,40.7504,zoom = 12) %>% addTiles()
    
    output$left_map <- renderLeaflet({
        if (input$adjust_crime=='Monthly average hate crime'){
            if (input$adjust_population == 'Yes'){
                map_base %>% addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                                         fillColor = ~pal(hate.pre.per.cap), label = ~paste0(boro_cd)) %>%
                    addLegend(pal = pal, values = ~hate.pre.per.cap, opacity = 1.0,
                              labFormat = labelFormat(transform = function(x) round(5e6*x)),title="Monthly total/5M people") %>%
                    addProviderTiles("CartoDB.Positron") 
            }else{
                map_base %>% addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                                         fillColor = ~pal(hate.pre), label = ~paste0(boro_cd)) %>%
                    addLegend(pal = pal, values = ~hate.pre, opacity = 1.0,
                              title="Monthly total") %>%
                    addProviderTiles("CartoDB.Positron")  
            }
        }else if (input$adjust_crime == 'Monthly average total arrest') {
            if (input$adjust_population == 'Yes'){
                map_base %>% addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                                         fillColor = ~pal(per.cap.pre), label = ~paste0(boro_cd)) %>%
                    addLegend(pal = pal, values = ~per.cap.pre, opacity = 1.0,
                              labFormat = labelFormat(transform = function(x) round(1e4*x)),title="Monthly total/10k people") %>%
                    addProviderTiles("CartoDB.Positron") 
            }else{
                map_base %>% addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                                         fillColor = ~pal(total.pre), label = ~paste0(boro_cd)) %>%
                    addLegend(pal = pal, values = ~total.pre, opacity = 1.0,
                              title="Monthly total") %>%
                    addProviderTiles("CartoDB.Positron")  
            }
        }
    })


    
    output$right_map <- renderLeaflet({
        if (input$adjust_crime=='Monthly average hate crime'){
            if (input$adjust_population == 'Yes'){
                map_base %>% addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                                         fillColor = ~pal(hate.post.per.cap), label = ~paste0(boro_cd)) %>%
                    addLegend(pal = pal, values = ~hate.post.per.cap, opacity = 1.0,
                              labFormat = labelFormat(transform = function(x) round(5e6*x)),title="Monthly total/5M people") %>%
                    addProviderTiles("CartoDB.Positron") 
            }else{
                map_base %>% addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                                         fillColor = ~pal(hate.post), label = ~paste0(boro_cd)) %>%
                    addLegend(pal = pal, values = ~hate.post, opacity = 1.0,
                              title="Monthly total") %>%
                    addProviderTiles("CartoDB.Positron")  
            }
        }else if(input$adjust_crime == 'Monthly average total arrest'){
            if (input$adjust_population == 'Yes'){
                map_base %>% addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                                         fillColor = ~pal(per.cap.post), label = ~paste0(boro_cd)) %>%
                    addLegend(pal = pal, values = ~per.cap.post, opacity = 1.0,
                              labFormat = labelFormat(transform = function(x) round(1e4*x)),title="Monthly total/10k people") %>%
                    addProviderTiles("CartoDB.Positron") 
            }else{
                map_base %>% addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
                                         fillColor = ~pal(total.post), label = ~paste0(boro_cd)) %>%
                    addLegend(pal = pal, values = ~total.post, opacity = 1.0,
                              title="Monthly total") %>%
                    addProviderTiles("CartoDB.Positron")  
            }
        }
    })
    
}
)

    # end of tab




