# ------------------------------------------------------------
# BUG HUNT 02   difficulty: *
# Symptom:  the app runs and there are no errors, but the
#           plot never shows up. The main area is empty.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(palmerpenguins)

ui <- page_sidebar(
  title = "Penguin body mass",
  sidebar = sidebar(
    checkboxGroupInput("species", "Species",
      choices = c("Adelie", "Chinstrap", "Gentoo"),
      selected = c("Adelie", "Chinstrap", "Gentoo")
    )
  ),
  #the plotOutput originally containted mass_plot which is different from what the 
  # plot is stored in so it wont render
  plotOutput("massplot")
)

server <- function(input, output) {
  output$massplot <- renderPlot({
    penguins |>
      filter(species %in% input$species) |>
      ggplot(aes(x = species, y = body_mass_g, fill = species)) +
      geom_boxplot() +
      theme_minimal()
  })
}

shinyApp(ui, server)
