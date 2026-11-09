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
library(ggrepel)

#this zone can be used for computations, or dataset loads...
#that do not change throughout the app

#------------Data-------------
languagesOfAfrica <- 
    read_csv("data/africa.csv") |>
    janitor::clean_names()  #no missing values

worldCountries <- ne_countries(scale = "medium", returnclass = "sf")

africaCountries <- worldCountries |> filter(continent == "Africa")


ui <- page_fillable(
  layout_sidebar(
    sidebar = sidebar(
      h1("Languages of Africa"),
      p("From TidyTuesday 2026-01-13")),
    card(
      card_header("Plot of Africa"),
      p("Plot of Africa"),
      plotOutput("AfricaPlot")
    )
  )
)
  


server <- function(input, output, session) {
output$AfricaPlot <- renderPlot({
  africaCountries |> ggplot() +
  geom_sf(fill = "lightblue", color = "white", linewidth = 0.3) +
  theme_void()
})
}

shinyApp(ui, server)