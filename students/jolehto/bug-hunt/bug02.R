# ------------------------------------------------------------
# BUG HUNT 02   difficulty: *
# Symptom:  the app runs and there are no errors, but the
#           plot never shows up. The main area is empty.
# Cause: plotOutput() had the variable mass_plot instead of massplot
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
