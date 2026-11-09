# ------------------------------------------------------------
# BUG HUNT 01   difficulty: *
# Symptom:  the app won't start. R stops with an error
#           before anything appears.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)

ui <- page_sidebar(
  title = "mtcars histogram",
  sidebar = sidebar(
    selectInput("var", "Variable", choices = c("mpg", "hp", "wt", "qsec")), # FIX: added a missing comma
    sliderInput("bins", "Number of bins", min = 5, max = 40, value = 15)
  ),
  plotOutput("hist")
)

server <- function(input, output) {
  output$hist <- renderPlot({
    ggplot(mtcars, aes(x = .data[[input$var]])) +
      geom_histogram(bins = input$bins, fill = "steelblue", color = "white") +
      theme_minimal()
  })
}

shinyApp(ui, server)
