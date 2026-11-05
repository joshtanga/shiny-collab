# ------------------------------------------------------------
# BUG HUNT 05   difficulty: **
# Symptom:  the app starts, but the plot area shows a red
#           error message instead of a plot.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(palmerpenguins)

ui <- page_sidebar(
  title = "Penguin flippers",
  sidebar = sidebar(
    sliderInput("mass", "Minimum body mass (g)",
      min = 2700, max = 6300, value = 3500, step = 100
    )
  ),
  plotOutput("flipper_plot")
)

server <- function(input, output) {
  # penguins at or above the chosen body mass
  heavy <- reactive({
    penguins |>
      filter(body_mass_g >= input$mass)
  })

  output$flipper_plot <- renderPlot({
    ggplot(heavy(), aes(x = flipper_length_mm, fill = species)) + # FIX: heavy needs () after because it is reactive
      geom_histogram(bins = 20) +
      theme_minimal()
  })
}

shinyApp(ui, server)
