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

#When the dataset was made from web scraping, some of the language family names
#were shortened in a sense that lost context/accuracy
# #(ie: Portuguese Creole becoming Portuguese)
languagesOfAfrica <- languagesOfAfrica |> mutate(family = case_when(
  family == "Afro-Asiatic" ~ "Afroasiatic",
  family == "Language" ~ "Isolated Language",
  family == "French" ~ "French Creole",
  family == "Arabic-based" ~ "Arabic-Based Creole",
  family == "English" ~ "English Creole",
  family == "Portugues" ~ "Portuguese Creole",
  family == "Kongo-based" ~ "Kongo-Based Creole",
  TRUE ~ family
))

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
    name == "W. Sahara" ~ "Western Sahara",
    name == "Dem. Rep. Congo" ~ "Democratic Republic of the Congo",
    TRUE ~ name 
  ))


africaLangsAndGeo <- merge(africaGeometry, languagesOfAfrica, 
  by.y = "country", by.x= "name", all = TRUE)|>
replace_na(list(
    language = "No Language Data", family = "No Language Data"))




ui <- page_fillable(
  layout_sidebar(
    sidebar = sidebar(
      h1("Languages of Africa"),
      
      p("From TidyTuesday 2026-01-13"),
      
      selectInput("Language",
        "Choose Language",
        choices = sort(unique(africaLangsAndGeo$language)),
        selected = sort(unique(africaLangsAndGeo$language))[1]),
      
      selectInput("Family",
        "Choose Language Family",
        choices = sort(unique(africaLangsAndGeo$family)),
        selected = sort(unique(africaLangsAndGeo$family))[1]),
      
      selectInput("Country",
        "Choose Country",
        choices = sort(unique(africaLangsAndGeo$name)),
        selected = sort(unique(africaLangsAndGeo$name))[1])),
    
    navset_card_tab(
    nav_panel("LangCountries", p("Fill in here later"), plotOutput("AfricaLangPlot")),
    nav_panel("FamCountries", p("Fill in here later"), plotOutput("AfricaFamPlot")),
    nav_panel("Langs In Country", tableOutput("LangsInCountryTable"))
    )
  )
)
  


server <- function(input, output, session) {
output$AfricaLangPlot <- renderPlot({
  
  africaLangsAndGeo <- africaLangsAndGeo |> mutate(
    langSpoken = case_when(
      language == input$Language ~ "Spoken",
      TRUE ~ "Not Spoken")
  )
  
  #arranged langSpoken because the map plots every country over and over for each language
  #in it, without the arrange, the map would plot a spoken version, and immediately
  #plot over it with a not spoken
  africaLangsAndGeo |> arrange(langSpoken) |> ggplot() +
  geom_sf(aes(fill = langSpoken)) +
  theme_void()
})

output$AfricaFamPlot <- renderPlot({
  
  africaLangsAndGeo <- africaLangsAndGeo |> mutate(
    famSpoken = case_when(
      family == input$Family ~ "Spoken",
      TRUE ~ "Not Spoken")
  )
  africaLangsAndGeo |> arrange(famSpoken) |> ggplot() +
  geom_sf(aes(fill = famSpoken)) +
  theme_void()
})
  
output$LangsInCountryTable <- renderTable({
  langsInCountry <- africaLangsAndGeo |> filter(name == input$Country) |>
    arrange(language)

  tibble(Language = langsInCountry$language,
    LanguageFamily = langsInCountry$family,
    NativeSpeakers = langsInCountry$native_speakers)

})

}

shinyApp(ui, server)