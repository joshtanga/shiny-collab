library(shiny)
library(bslib)
library(tidyverse)
library(janitor)

VideoG <- read_csv("data/VideoGameData.csv") |>
  clean_names()

glimpse(VideoG)

data <- VideoG |>
  select(name, platform, year_of_release, genre, publisher, na_sales, eu_sales, global_sales)

missing_values <- data |>
  summarise(across(everything(), ~sum(is.na(.x)))) |>
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_count"
  )

missing_values

data <- data |>
  drop_na(name, platform, year_of_release, genre, publisher, na_sales, eu_sales, global_sales) |>
  mutate(year_of_release = as.integer(year_of_release))
ui <- page_sidebar(
  title = "Video Game Publisher Sales",

  
)

server <- function(input, output){

}

shinyApp(ui, server)