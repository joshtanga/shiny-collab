# ------------------------------------------------------------
# BUG HUNT 08   difficulty: **
# Symptom:  no errors, and the plot works for two of the
#           species. For the third, the plot is empty.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(palmerpenguins)

ui <- page_sidebar(
  title = "Bills by species",
  sidebar = sidebar(
    radioButtons("sp", "Species",
      choices = c("Adelie", "Chinstrap", "Gentoo") # FIX: fixed capitalization on Gentoo
    )
  ),
  plotOutput("bill_plot")
)

server <- function(input, output) {
  output$bill_plot <- renderPlot({
    penguins |>
      filter(species == input$sp) |>
      ggplot(aes(x = bill_length_mm, y = bill_depth_mm)) +
      geom_point(size = 3, color = "purple") +
      labs(title = input$sp) +
      theme_minimal()
  })
}

shinyApp(ui, server)
