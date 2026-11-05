# ------------------------------------------------------------
# BUG HUNT 07   difficulty: **
# Symptom:  a plot shows up when the app opens, but clicking
#           "New sample" does nothing. The plot never changes.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(palmerpenguins)

ui <- page_sidebar(
  title = "Bootstrap a penguin sample",
  sidebar = sidebar(
    actionButton("resample", "New sample")
  ),
  plotOutput("boot_plot")
)

server <- function(input, output) {
  # a random sample of 50 penguins
  boot <- eventReactive(input$resample, { # FIX: change to eventReactive
    penguins |>
      drop_na(bill_length_mm) |>
      slice_sample(n = 50)
  }, ignoreNULL = FALSE) # FIX: add ignoreNULL = FALSE so the plot is initialized without input

  output$boot_plot <- renderPlot({
    ggplot(boot(), aes(x = bill_length_mm, fill = species)) +
      geom_histogram(bins = 15) +
      theme_minimal()
  })
}

shinyApp(ui, server)
