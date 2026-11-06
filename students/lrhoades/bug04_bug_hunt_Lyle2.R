# ------------------------------------------------------------
# BUG HUNT 04   difficulty: **
# Symptom:  no errors, but the "scatterplot" is a single
#           dot (or one stack of dots) with the variable's
#           NAME on the axis, whichever variables you pick.
# To fix this bug aes the input$xvar and input$yvar were treated as text and not actual values to plot
# using the .data tells ggplot to use the actualy use the selected columns to show the points 
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
    ggplot(mtcars, aes(x = .data[[input$xvar]], y = .data[[input$yvar]])) +
      geom_point(size = 3) +
      labs(x = input$xvar, y = input$yvar) +
      theme_minimal()
  })
}

shinyApp(ui, server)
