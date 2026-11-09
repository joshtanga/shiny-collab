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

#the aes was only getting a string value of variable in the data, need to add get to convert value to varible in data
server <- function(input, output) {
  output$scatter <- renderPlot({
    ggplot(mtcars, aes(x = get(input$xvar), y = get(input$yvar))) +
      geom_point(size = 3) +
      labs(x = input$xvar, y = input$yvar) +
      theme_minimal()
  })
}

shinyApp(ui, server)
