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

ui <- page_fluid(
  #inside goes lots of things
  #all of which pertain to the UI
  #initially
  
)

server <- function(input, output, session) {
#inside here goes the guts/computations that do change: plot stuff, mutates, etc.

  #sanity savers:
  #shiny tends to produce lots of nested paranthesis
}

shinyApp(ui, server)