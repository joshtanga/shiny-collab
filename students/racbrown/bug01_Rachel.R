# ------------------------------------------------------------
# BUG HUNT 01   difficulty: *
# Symptom:  the app won't start. R stops with an error
#           before anything appears.
# ------------------------------------------------------------
# The change was adding a comma at the end of the line 14
library(shiny)
library(bslib)
library(tidyverse)

ui <- page_sidebar(
  title = "mtcars histogram",
  sidebar = sidebar(
    selectInput("var", "Variable", choices = c("mpg", "hp", "wt", "qsec")), # Change
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
