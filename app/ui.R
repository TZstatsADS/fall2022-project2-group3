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
if (!require("shinydashboard")) {
  install.packages("shinydashboard")
  library(shinydashboard)
}
# 

# Define UI ----
                              
shinyUI(
  navbarPage(strong("NYC Crime Study",style="color: white;"), 
             theme=shinytheme("superhero"), # select your themes https://rstudio.github.io/shinythemes/
             
             tabPanel("Introduction",icon=icon("fa-duotone fa-house",verify_fa = FALSE),
                      fluidPage(
                        fluidRow(
                            column(6,h2("How civid affect crimes in NYC"),
                                   h3("Jinyang Cai, Chengming He, Jiapeng Xu"),
                                   p("In this project, we analyzed the effect of covid on NYC crime related data.")),
                            column(6,img(class="img-polaroid",
                                         src='https://images.unsplash.com/photo-1585236534996-3b117bec1b61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2787&q=80',
                                         style="width: 400px",align="right"),
                            column(12,tags$small("Photo by Alec Favale on Unsplash",style = "text-align: right"),
                                   offset=6)
                                   )
                        
                      ))),
             #----------------------------- tab panel - Maps Chengming He-------------------------------
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
             ), #tabPanel maps closing
             #------------------------------- tab panel - Jinyang Cai ---------------------------------
             tabPanel("Arrest Data", 
                      fluidPage(
                        titlePanel("Arrest Cases - Borough"), 
                        sidebarLayout(
                          sidebarPanel(
                            prettyRadioButtons(
                              inputId = "num_year_boro",
                              label = "Year List:",
                              choices = c(2018, 2019, 2020, 2021)
                            )
                          ),
                          mainPanel(
                            plotOutput(outputId = "year_boro")
                          )
                        )
                      ),
                      fluidPage(
                        titlePanel("2020 Arrest Cases - Borough"), 
                        sidebarLayout(
                          sidebarPanel(
                            prettyRadioButtons(
                              inputId = "boro_input_twenty",
                              label = "Borough List:",
                              choices = c("Bronx", "Staten Island", "Brooklyn", "Manhattan", "Queens")
                            )
                          ),
                          mainPanel(
                            plotOutput(outputId = "boro_twenty")
                          )
                        )
                      ),
                      fluidPage(
                        titlePanel("Top 10 Categories of Arrest"), 
                        sidebarLayout(
                          sidebarPanel(
                            prettyRadioButtons(
                              inputId = "pd_desc",
                              label = "Categoty List:",
                              choices = c("ASSAULT 3", "LARCENY,PETIT FROM OPEN AREAS,", "ASSAULT 2,1,UNCLASSIFIED", "TRAFFIC,UNCLASSIFIED MISDEMEAN", "ROBBERY,OPEN AREA UNCLASSIFIED",
                                          "LARCENY,PETIT FROM OPEN AREAS,UNCLASSIFIED", "PUBLIC ADMINISTRATION,UNCLASSI", "LARCENY,GRAND FROM OPEN AREAS, UNATTENDED", "CONTROLLED SUBSTANCE, POSSESSI", "MENACING,UNCLASSIFIED")
                            ),
                            width = 4
                          ),
                          mainPanel(
                            plotOutput(outputId = "desc_pd")
                          )
                        )
                      ),
                      fluidPage(
                        titlePanel("Arrest Cases Divide by Features"), 
                        sidebarLayout(
                          sidebarPanel(
                            prettyRadioButtons(
                              inputId = "feature",
                              label = "Feature List:",
                              choices = c("Age Group", "Gender", "Level of Offense")
                            )
                          ),
                          mainPanel(
                            plotOutput(outputId = "feature_line")
                          )
                        )
                      )
             ),
             
             
             #------------------------------- tab panel - Jinyang Cai ---------------------------------
             
             #------------------------------- tab panel - Homeless study ------------------------------
             tabPanel('Homeless Data',
                      icon = icon("map-marker-alt",verify_fa = FALSE), 
                      fluidPage(
                        
                        titlePanel("Infomation about categories of homeless"),
                        
                        sidebarLayout(
                          sidebarPanel( 
                            selectInput('Select1',
                                        'Category',
                                        c('Total Adults in Shelter' = 'Total.Adults.in.Shelter', 
                                          'Total Children in Shelter' = 'Total.Children.in.Shelter', 
                                          'Total Individuals in Shelter' = 'Total.Individuals.in.Shelter',
                                          'Single Adult Men in Shelter' = 'Single.Adult.Men.in.Shelter',
                                          'Single Adult Women in Shelter' = 'Single.Adult.Women.in.Shelter',
                                          'Total Single Adults in Shelter' = 'Total.Single.Adults.in.Shelter',
                                          'Adults in Families with Children in Shelter' = 'Adults.in.Families.with.Children.in.Shelter',
                                          'Children in Families with Children in Shelter' = 'Children.in.Families.with.Children.in.Shelter',
                                          'Total Individuals in Families with Children in Shelter' = 'Total.Individuals.in.Families.with.Children.in.Shelter',
                                          'Individuals in Adult Families in Shelter' = 'Individuals.in.Adult.Families.in.Shelter'),
                                        multiple = TRUE
                                        )
                            ),
                          mainPanel(
                            plotOutput('BarPlot'),
                            plotOutput('TS')
                            )# End of mainPanel
                          )# End of sidebarLayout
                      ), # End of fluidPage
                      fluidPage(
                        
                        titlePanel("Homeless by borough"),
                        
                        sidebarLayout(
                          sidebarPanel(
                            selectInput('Select2',
                                        'Category',
                                        c('Bronx', 
                                          'Brooklyn', 
                                          'Manhattan',
                                          'Queens',
                                          'Staten Island'),
                                        multiple = TRUE
                                        )
                            ),
                          mainPanel( plotOutput('Borough') )
                          )# End of sidebarLayout
                        )# End of fluidPage
                      )# End of tabPanel
             #------------------------------- tab panel - Homeless study ------------------------------
             
             
             
  ) #navbarPage closing  
) #Shiny UI closing   