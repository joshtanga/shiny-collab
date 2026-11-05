# ------------------------------------------------------------
# BUG HUNT 06   difficulty: **
# Symptom:  when the app first opens, the plot area is
#           completely blank. It only shows a plot after
#           you click the button.
# Goal:     a plot should appear right away, and a new one
#           on every click.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)

ui <- page_sidebar(
  title = "Random sample of cars",
  sidebar = sidebar(
    actionButton("draw", "Draw 10 random cars")
  ),
  plotOutput("sample_plot")
)

server <- function(input, output) {
  # a new random sample of 10 cars each time the button is clicked
  cars_sample <- eventReactive(input$draw, {
    mtcars |>
      rownames_to_column("car") |>
      slice_sample(n = 10)
  })

  output$sample_plot <- renderPlot({
    ggplot(cars_sample(), aes(x = mpg, y = reorder(car, mpg))) +
      geom_col(fill = "darkorange") +
      labs(y = NULL) +
      theme_minimal()
  })
}

shinyApp(ui, server)
