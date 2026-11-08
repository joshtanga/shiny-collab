# ------------------------------------------------------------
# BUG HUNT 04   difficulty: **
# Symptom:  no errors, but the "scatterplot" is a single
#           dot (or one stack of dots) with the variable's
#           NAME on the axis, whichever variables you pick.
# FIX: on line 26 "ggplot(mtcars,..." in aes() it was selecting only the
# variable names. I fixed it to select for the data for the imput variable.
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
