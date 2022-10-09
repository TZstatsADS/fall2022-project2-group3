if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}
if (!require("shinyWidgets")) {
  install.packages("shinyWidgets")
  library(shinyWidgets)
}
if (!require("shinythemes")) {
  install.packages("shinythemes")
  library(shinythemes)
}
if (!require("leaflet")) {
  install.packages("leaflet")
  library(leaflet)
}
if (!require("leaflet.extras")) {
  install.packages("leaflet.extras")
  library(leaflet.extras)
}

# Define UI ----
                              
shinyUI(
  navbarPage(strong("NYC Crime Study",style="color: white;"), 
             theme=shinytheme("superhero"), # select your themes https://rstudio.github.io/shinythemes/
             
             tabPanel("Introduction",icon=icon("fa-duotone fa-house",verify_fa = FALSE),
                      fluidPage(
                        fluidRow(box(width = 15, title = "Introduction", status = "primary",
                                     solidHeader = TRUE, h3("Covid-19 and NYC Crime"),) ) ) ) ,
             #------------------------------- tab panel - Maps ---------------------------------
             tabPanel("Maps",
                      icon = icon("map-marker-alt",verify_fa = FALSE), #choose the icon for
                      div(class = 'outer',
                          # side by side plots
                          fluidRow(
                            splitLayout(cellWidths = c("50%", "50%"), 
                                        leafletOutput("left_map",width="100%",height=1200),
                                        leafletOutput("right_map",width="100%",height=1200))),
                          #control panel on the left
                          absolutePanel(id = "control", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                        top = 200, left = 50, right = "auto", bottom = "auto", width = 250, height = "auto",
                                        tags$h4('NYC Crime Comparison'), 
                                        tags$br(),
                                        tags$h5('Pre-covid(Left) Right(Right)'), 
                                        awesomeRadio("adjust_crime", 
                                                     label="Crime",
                                                     choices =c("Monthly average total arrest",
                                                                "Monthly average hate crime"), 
                                                     selected = "Monthly average total arrest",
                                                     status = "warning"),
                                        selectInput('adjust_population',
                                                    label = 'Adjust for Population',
                                                    choices = c('Yes','No'),
                                                    selected = 'No'
                                                    ),
                                        style = "opacity: 0.75"
                                        
                          ), #Panel Control - Closing
                      ) #Maps - Div closing
             ) #tabPanel maps closing
             
             
             
  ) #navbarPage closing  
) #Shiny UI closing   