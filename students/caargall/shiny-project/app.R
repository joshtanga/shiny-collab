#Where are most meteorites found? Has that changed over time?
library(tidyverse)
library(shiny)
library(maps)


meteor <- read_csv("data/meteorite-landings.csv") |>
  janitor::clean_names()

meteor |> summarize(
    across(everything(), ~ sum(is.na(.x)))
)

meteorClean <- meteor |>
  filter(
    (year >= 860 & year <= 2016),
    (reclong <= 180 & reclong >= -180 & (reclat!=0 | reclong!=0)),
    mass != "NA")

meteorClean |> summarize(
    across(everything(), ~ sum(is.na(.x)))
)

##ui <- page_fillable(
 
#)

server <- function(input, output) {

}

shinyApp(ui, server)

