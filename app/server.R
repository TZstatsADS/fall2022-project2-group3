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
if (!require("tidyr")) {
    install.packages("tidyr")
    library(tidyr)
}
if (!require("ggplot2")) {
    install.packages("ggplot2")
    library(ggplot2)
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

#     ####################### Data preprocess for homeless data ##################
# read csv
Homeless_data <-  read.csv('../data/DHS_Daily_Report.csv', header = TRUE)
Covid_data <- read.csv('../data/COVID-19_Daily_Counts_of_Cases__Hospitalizations__and_Deaths.csv', 
                       header = TRUE)[,c(1,7)]
Homeless_Borough_data <-  read.csv('../data/Individual_Census_by_Borough__Community_District__and_Facility_Type.csv', 
                                   header = TRUE)
# data preprocess for the 1st diagram
Homeless_data$Date.of.Census <- as.Date(Homeless_data$Date.of.Census , format = "%m/%d/%Y")
Homeless_data <- Homeless_data[!duplicated(Homeless_data), ]
Homeless_data <- Homeless_data[order(Homeless_data$Date.of.Census, decreasing = TRUE), ]
Homeless_data <- Homeless_data[Homeless_data$Date.of.Census >= '2018-01-01', ]
barplot_data = t(Homeless_data[1, -1])
colnames(barplot_data) = 'Number'
barplot_data = as.data.frame(barplot_data)
barplot_data$Category = rownames(barplot_data)

# data preprocess for the 2nd diagram
Covid_data$date_of_interest <- as.Date(Covid_data$date_of_interest, format = "%m/%d/%Y")
tsplot_data = merge(x = Homeless_data, 
                    y = Covid_data, 
                    by = 1, 
                    all.x =  TRUE)
colnames(tsplot_data)[14] <- 'Covid.Case.Count'
tsplot_data_new = tsplot_data %>%
  as_tibble() %>%
  pivot_longer(-1)
colnames(tsplot_data_new)[2] <- 'Category'

# data preprocess for the 3rd diagram
Homeless_Borough_data[is.na(Homeless_Borough_data)] <- 0
Homeless_Borough_data$individuals <- apply(Homeless_Borough_data[,-(1:4)], 1, sum)
Homeless_Borough_data_gb <- Homeless_Borough_data %>% 
  group_by(Borough) %>%
  summarize(total.number.of.individuals = sum(individuals))
#     ############################################################################

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
    #------------------------------- Homeless study ---------------------------------
    
    output$BarPlot <- renderPlot({
      
      newdata <- barplot_data[input$Select1,]
      
      ggplot(data = newdata, aes(x = Category, y = Number)) +  
        geom_bar(stat = 'identity') + 
        ggtitle("The number of different kinds of homeless") +
        theme(axis.text.x=element_text(angle = -60, hjust = 0))
    })
    
    output$TS <- renderPlot({
      
      ggplot(data = tsplot_data_new[tsplot_data_new$Category %in% c(input$Select1, c('Covid.Case.Count')),], aes(x = Date.of.Census, y = value, color = Category)) +
        geom_line() + 
        labs(title = "Time series of different kinds of homeless", x = "Date") +
        theme(legend.position="bottom")
    })
    
    output$Borough <- renderPlot({
      
      newdata2 <- Homeless_Borough_data_gb[Homeless_Borough_data_gb$Borough %in% input$Select2,]
      
      ggplot(data = newdata2, aes(x = Borough, y = total.number.of.individuals)) +  
        geom_bar(stat = 'identity') + 
        labs(y = "Total number of individuals")
      
    })
    
    #------------------------------- Homeless study ---------------------------------
    
}
)

    # end of tab




