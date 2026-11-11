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
library(ggiraph)

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
  TRUE ~ family))

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
    language = "No Language Data", family = "No Language Data", native_speakers = 0))




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
        selected = sort(unique(africaLangsAndGeo$name))[1]),
    
      numericInput("SpeakerNumMin",
      "Set Min Number of Native Speakers",
      min = min(africaLangsAndGeo$native_speakers),
      max = max(africaLangsAndGeo$native_speakers),
      value = min(africaLangsAndGeo$native_speakers),
      step = 100),

      numericInput("SpeakerNumMax",
      "Set Max Number of Native Speakers",
      min = min(africaLangsAndGeo$native_speakers),
      max = max(africaLangsAndGeo$native_speakers),
      value = max(africaLangsAndGeo$native_speakers),
      step = 100)
      ),
    
    navset_card_tab(
    nav_panel("Language Map",
      p("Choose a language to show what countries that language is spoken in."),
      girafeOutput("AfricaLangPlot")),
    nav_panel("Language Family Map",
      p("Choose a language family to show what countries that language family is spoken in."),
      girafeOutput("AfricaFamPlot")),
    nav_panel("Country's Languages Table",
      p("Choose a country, and adjust the min and max of numbers of native speakers to see what languages are spoken in that country within the native speaker range."),
      tableOutput("LangsInCountryTable")),
    nav_panel("Native Speakers Plot",
      p("Adjust the min and max of numbers of native speakers to see what languages have a number of native speakers in that range."),
      girafeOutput("NativeSpeakerPlot"))
    )
  )
)
  


server <- function(input, output, session) {
  
output$AfricaLangPlot <- renderGirafe({
  
  africaLangsAndGeo <- africaLangsAndGeo |> mutate(
    langSpoken = case_when(
      language == input$Language ~ "Spoken",
      TRUE ~ "Not Spoken")
  )
  
  #arranged langSpoken because the map plots every country over and over for each language
  #in it, without the arrange, the map would plot a spoken version, and immediately
  #plot over it with a not spoken
  langMap <- africaLangsAndGeo |> arrange(langSpoken) |> ggplot() +
  geom_sf_interactive(aes(fill = langSpoken,tooltip = name,data_id=name)) +
  theme_void()+
  labs(fill=input$Language, 
    title = paste("Where is", input$Language, "spoken in Africa?"))
  
  girafe(ggobj = langMap)
})

output$AfricaFamPlot <- renderGirafe({
  
  africaLangsAndGeo <- africaLangsAndGeo |> mutate(
    famSpoken = case_when(
      family == input$Family ~ "Spoken",
      TRUE ~ "Not Spoken")
  )
  famMap <- africaLangsAndGeo |> arrange(famSpoken) |> ggplot() +
  geom_sf_interactive(aes(fill = famSpoken,tooltip = name,data_id=name)) +
  theme_void() +
  labs(fill=input$Family,
  title = paste("Where is the", input$Family, "language family spoken in Africa?"))
girafe(ggobj = famMap)
})
  
  
  filteredAfricaLangsAndGeo <- reactive({
    africaLangsAndGeo |>
    filter(native_speakers >= input$SpeakerNumMin &
      native_speakers <= input$SpeakerNumMax)
})
  
output$LangsInCountryTable <- renderTable({
  langsInCountry <- filteredAfricaLangsAndGeo()|> 
    filter(name == input$Country) |> arrange(language)

  tibble(Language = langsInCountry$language,
    Language_Family = langsInCountry$family,
    Native_Speakers = langsInCountry$native_speakers)
})
  
output$NativeSpeakerPlot <- renderGirafe({
  nativeSpeakPlot <- filteredAfricaLangsAndGeo()|>
    filter(language != "No Language Data") |>
    ggplot(aes(y=family,x=native_speakers,color = family)) +
    geom_point_interactive(aes(tooltip=language,data_id=language)) +
    scale_x_continuous(labels = comma) +
    scale_color_viridis_d(option = "turbo") +
    theme(legend.position = "none") +
    labs(x="Number of Native Speakers", y="Language Family",
      title="Native Speakers of Languages by Language Family")

  girafe(ggobj = nativeSpeakPlot)

})

}

shinyApp(ui, server)