# Library
library(shiny)
library(bslib)
library(tidyverse)
library(janitor)

# Importing Data and Cleaning it
temperature <- read_csv("annual-temperaturenew.csv") |>
  clean_names() |>
  rename(country = conutry)
# looked for na values and found none.
# did a glimpse(temperature) to check variables
# renamed country 

ui <- page_sidebar( # page with a sidebar for controls
  # creating a sidebar
  title = "Global Temperature Explorer",
  sidebar = sidebar(
    p("Select a country and year to explore temperature data")
  )
)

server <- function(input,output){
  # R-code for data-wrangling & plotting
}

# Run the application 
shinyApp(ui = ui, server = server)