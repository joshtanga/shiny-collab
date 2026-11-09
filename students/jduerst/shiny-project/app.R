# ------------------------------------------------------------
# App:        app.R
# Author:     Janson Duerst
# Shiny Project: Languages of Africa
# ------------------------------------------------------------

library(shiny)
library(bslib)
library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(scales)

#this zone can be used for computations, or dataset loads...
#that do not change throughout the app

#------------Data-------------
languagesOfAfrica <- 
    read_csv("data/africa.csv") |>
    janitor::clean_names()  #no missing values

#To get geometry for mapping Africa
africaGeometry <- ne_countries(scale = "medium", returnclass = "sf") |>
  filter(continent == "Africa") |> select(name,geometry)

#The two datasets have different ways to refer to the following countries,
#Made them the same in order to keep data with the correct country
africaGeometry <- africaGeometry |> mutate(name = case_when(
    name == "Côte d'Ivoire"   ~ "Ivory Coast",
    name == "Central African Rep." ~ "Central African Republic",
    name == "S. Sudan" ~ "South Sudan",
    name == "Eq. Guinea" ~ "Equatorial Guinea",
    name == "Cabo Verde" ~ "Cape Verde",
    name == "eSwatini" ~ "Eswatini",
    TRUE              ~ name # Keeps all other scores the same
  ))


africaLangsAndGeo <- merge(africaGeometry, languagesOfAfrica, 
  by.y = "country", by.x= "name", all = TRUE)|>
replace_na(list(
    language = "No Language Data"))


ui <- page_fillable(
  layout_sidebar(
    sidebar = sidebar(
      h1("Languages of Africa"),
      
      p("From TidyTuesday 2026-01-13"),
      
      selectInput("Language",
        "Choose Language",
        choices = sort(unique(africaLangsAndGeo$language)),
        selected = sort(unique(africaLangsAndGeo$language))[1])),
    
    card(
      card_header("Plot of Africa"),
      p("Plot of Africa"),
      plotOutput("AfricaPlot"))
  )
)
  


server <- function(input, output, session) {
output$AfricaPlot <- renderPlot({
  
  africaLangsAndGeo <- africaLangsAndGeo |> mutate(
    spoken = case_when(
      language == input$Language ~ "Spoken",
      TRUE ~ "Not Spoken")
  )
  
  #arranged spoken because the map plots every country over and over for each language
  #in it, without the arrange, the map would plot a spoken version, and immediately
  #plot over it with a not spoken
  africaLangsAndGeo |> arrange(spoken) |> ggplot() +
  geom_sf(aes(fill = spoken)) +
  theme_void()
})
}

shinyApp(ui, server)