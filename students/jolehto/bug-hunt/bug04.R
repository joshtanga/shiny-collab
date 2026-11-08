# ------------------------------------------------------------
# BUG HUNT 04   difficulty: **
# Symptom:  no errors, but the "scatterplot" is a single
#           dot (or one stack of dots) with the variable's
#           NAME on the axis, whichever variables you pick.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)

num_vars <- names(mtcars)

ui <- page_sidebar(
  title = "mtcars explorer",
  sidebar = sidebar(
    selectInput("xvar", "x variable", choices = num_vars, selected = "wt"),
    selectInput("yvar", "y variable", choices = num_vars, selected = "mpg")
  ),
  plotOutput("scatter")
)

server <- function(input, output) {
  output$scatter <- renderPlot({
    ggplot(mtcars, aes(x = .data[[input$xvar]], y = .data[[input$yvar]])) + # FIX: use column data instead of plotting the string - changing aes to aes_string also works - got help from: https://stackoverflow.com/questions/75824010/in-ggplot2-what-is-the-replacement-method-for-the-aes-string-function
      geom_point(size = 3) +
      labs(x = input$xvar, y = input$yvar) +
      theme_minimal()
  })
}

shinyApp(ui, server)
