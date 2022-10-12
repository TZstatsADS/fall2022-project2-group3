#Chengming He

library(geojsonio)
library(tidyverse)
library(sf)
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

##################################Loading data##################################
df.pop <- read.csv("../data/New_York_City_Population_By_Community_Districts.csv")
df <- read.csv("../data/NYPD_Arrests_Data__Historic_.csv")
df.hate <- read.csv("../data/NYPD_Hate_Crimes.csv")
df.shoot <- read.csv("../data/NYPD_Shooting_Incident_Data__Historic_.csv")
url <- "https://data.cityofnewyork.us/api/geospatial/yfnk-k7r4?method=export&format=GeoJSON"
file.name <- "../data/nyc_community_districts.geojson"
download.file(url,file.name)
nyc_districts <- geojson_read(file.name, what="sp")

######################### Process arrest data ##################################
df <- df %>% mutate(ARREST_DATE=as.Date(df$ARREST_DATE,"%m/%d/%Y")) %>%
  arrange(ARREST_DATE) %>% filter(ARREST_DATE > as.Date("1/1/2018","%m/%d/%Y"))
sf <- sf::st_read("../data/nyc_community_districts.geojson")
x <- df[c("Longitude","Latitude")]
sf_x <- sf::st_as_sf(x, coords = c("Longitude","Latitude"))
st_crs(sf_x) <- st_crs(sf)
res <- st_within(sf_x, sf)
helper = function(v){
  return(v[1])
}
df$poly_num <- sapply(res,helper)

arrest.total.post <- df %>% filter(!is.na(df$poly_num))%>%
  filter(ARREST_DATE>=as.Date("2020-3-1")) %>% 
  group_by(poly_num) %>% tally() 
arrest.total.post <- arrest.total.post[order(arrest.total.post$poly_num),]
arrest.total.pre <- df %>% filter(!is.na(df$poly_num))%>%
  filter(ARREST_DATE<as.Date("2020-3-1")) %>% 
  group_by(poly_num) %>% tally() 
arrest.total.pre <- arrest.total.pre[order(arrest.total.pre$poly_num),]
######################### Process shoot data ##################################
df.shoot <- df.shoot %>% mutate(OCCUR_DATE=as.Date(df.shoot$OCCUR_DATE,"%m/%d/%Y")) %>%
  arrange(OCCUR_DATE) %>% filter(OCCUR_DATE > as.Date("1/1/2018","%m/%d/%Y"))
x.shoot <- df.shoot[c("Longitude","Latitude")]
sf_x <- sf::st_as_sf(x.shoot, coords = c("Longitude","Latitude"))
st_crs(sf_x) <- st_crs(sf)
res <- st_within(sf_x, sf)
helper = function(v){
  return(v[1])
}
df.shoot$poly_num <- sapply(res,helper)

shoot.total.post <- df.shoot %>% filter(!is.na(df.shoot$poly_num))%>%
  filter(OCCUR_DATE>=as.Date("2020-3-1")) %>% 
  group_by(poly_num) %>% tally() 
shoot.total.post <- shoot.total.post[order(shoot.total.post$poly_num),]
shoot.total.pre <- df.shoot %>% filter(!is.na(df.shoot$poly_num))%>%
  filter(OCCUR_DATE<as.Date("2020-3-1")) %>% 
  group_by(poly_num) %>% tally() 
shoot.total.pre <- shoot.total.pre[order(shoot.total.pre$poly_num),]
######################## Process population data ###############################
word2num <- function(v){
  if (v=="Manhattan"){return(1)}
  if (v=="Bronx"){return(2)}
  if (v=="Brooklyn"){return(3)}
  if (v=="Queens"){return(4)}
  if (v=="Staten Island"){return(5)}
}
df.pop$boro_cd <- 0
for (i in 1:nrow(df.pop)){
  if (df.pop$CD.Number[i] < 10){
    df.pop$boro_cd[i] <- paste(word2num(df.pop$Borough[i]),df.pop$CD.Number[i],sep = '0')
  }else{
    df.pop$boro_cd[i] <- paste(word2num(df.pop$Borough[i]),df.pop$CD.Number[i],sep = '')
  }
}

###########################Process hate data ###################################
MONTH.PRE <- 14
MONTH.POST <- 28
df.hate$month.year = paste(df.hate$Complaint.Year.Number,df.hate$Month.Number,sep='-')
df.hate <- df.hate[order(df.hate$month.year),]
code <- function(strings){
  v <- str_split(strings, " ")[[1]][3]
  if (v=="MAN"){return(1)}
  if (v=="BRONX"){return(2)}
  if (v=="BKLYN"){return(3)}
  if (v=="QUEENS"){return(4)}
  if (v=="STATEN"){return(5)}
}
df.hate$boro_code <- apply(df.hate[c("Patrol.Borough.Name")],MARGIN = 1,FUN=code)
hate.post <- df.hate %>%
  filter(month.year>="2020-3") %>% 
  group_by(boro_code) %>% tally() 
hate.pre <- df.hate %>%
  filter(month.year<"2020-3") %>% 
  group_by(boro_code) %>% tally() 

order_boro <- c("Manhattan","Bronx","Brooklyn","Queens","Staten Island")
boro_pop <- df.pop %>% group_by(Borough) %>% summarise(total=sum(X2010.Population))
boro_pop <- boro_pop[match(order_boro,boro_pop$Borough),]
hate.pre$n <- hate.pre$n / MONTH.PRE
hate.post$n <- hate.post$n / MONTH.POST
hate.pre$per.cap <- hate.pre$n / (MONTH.PRE*boro_pop$total)
hate.post$per.cap <- hate.post$n / (MONTH.POST*boro_pop$total)

sf$hate.post <- 0
sf$hate.pre <- 0
sf$hate.post.per.cap <- 0
sf$hate.pre.per.cap <- 0
for (i in 1:nrow(sf)){
  boro <- sf$boro_cd[i]
  sf$hate.post[i] <- as.numeric(hate.post[as.integer(substr(boro,1,1)),2])
  sf$hate.post.per.cap[i] <- as.numeric(hate.post[as.integer(substr(boro,1,1)),3])
  sf$hate.pre[i] <- as.numeric(hate.pre[as.integer(substr(boro,1,1)),2])
  sf$hate.pre.per.cap[i] <- as.numeric(hate.pre[as.integer(substr(boro,1,1)),3])
}

##########################Process geojson data #################################
sf$total.post <- 0
sf$total.pre <- 0
sf$per.cap.post <- 0
sf$per.cap.pre <- 0
sf$total.shoot.post <- 0
sf$total.shoot.pre <- 0
sf$per.cap.shoot.post <- 0
sf$per.cap.shoot.pre <- 0
NUM.MONTH.PRE <- 26
NUM.MONTH.POST <- 22
for (i in 1:nrow(arrest.total.pre)){
  boro <- sf$boro_cd[as.numeric(arrest.total.pre[i,1])]
  mask <- (df.pop$boro_cd == boro)
  if (any(mask)){
    pop <- df.pop[which(mask),]$X2010.Population
    sf$total.pre[as.numeric(arrest.total.pre[i,1])] <- 
      as.numeric(arrest.total.pre[i,2])/NUM.MONTH.PRE
    sf$per.cap.pre[as.numeric(arrest.total.pre[i,1])] <- 
      as.numeric(arrest.total.pre[i,2])/(pop*NUM.MONTH.PRE)
    sf$total.shoot.pre[as.numeric(shoot.total.pre[i,1])] <-
      as.numeric(shoot.total.pre[i,2])/NUM.MONTH.POST
    sf$per.cap.shoot.pre[as.numeric(shoot.total.pre[i,1])] <- 
      as.numeric(shoot.total.pre[i,2])/(pop*NUM.MONTH.POST)    
  }
}
for (i in 1:nrow(arrest.total.post)){
  boro <- sf$boro_cd[as.numeric(arrest.total.post[i,1])]
  mask <- (df.pop$boro_cd == boro)
  if (any(mask)){
    pop <- df.pop[which(mask),]$X2010.Population
    sf$total.post[as.numeric(arrest.total.post[i,1])] <-
      as.numeric(arrest.total.post[i,2])/NUM.MONTH.POST
    sf$per.cap.post[as.numeric(arrest.total.post[i,1])] <- 
      as.numeric(arrest.total.post[i,2])/(pop*NUM.MONTH.POST)
    sf$total.shoot.post[as.numeric(shoot.total.post[i,1])] <-
      as.numeric(shoot.total.post[i,2])/NUM.MONTH.POST
    sf$per.cap.shoot.post[as.numeric(shoot.total.post[i,1])] <- 
      as.numeric(shoot.total.post[i,2])/(pop*NUM.MONTH.POST)
  }
}



######################## Write processed data ##################################

used_attr <- c("ARREST_DATE","PD_DESC","AGE_GROUP","PERP_SEX","Latitude","Longitude","poly_num",
               "ARREST_BORO","LAW_CAT_CD")
df <- df[used_attr]
write.csv(df,"../processed/nyc_arrest_processed.csv")
st_write(sf, dsn = "../processed/nyc_community_districts_processed.geojson",delete_dsn=T)













