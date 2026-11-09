# ------------------------------------------------------------
# BUG HUNT 10   difficulty: ***
# Symptom:  click a point and, for a split second, it turns
#           red and its details appear in the table... then
#           both disappear. The selection won't "stick".
# Goal:     the clicked car should stay red, and stay in the
#           table, until you click a different point.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)

cars <- mtcars |> rownames_to_column("car")

ui <- page_sidebar(
  title = "Click a car",
  sidebar = sidebar(
    p("Click a point to see that car's details."),
    tableOutput("car_info")
  ),
  plotOutput("scatter", click = "plot_click")
)

server <- function(input, output) {
  # the car nearest the click (0 rows if nothing is near)
  clicked_car <- reactive({
    nearPoints(cars, input$plot_click, xvar = "wt", yvar = "mpg", maxpoints = 1)
  })

  output$scatter <- renderPlot({
    ggplot(cars, aes(x = wt, y = mpg)) +
      geom_point(size = 3, color = "grey50") +
      # draw the clicked car in red on top
      geom_point(data = clicked_car(), size = 5, color = "red") +
      theme_minimal()
  })

  output$car_info <- renderTable({
    clicked_car() |> select(car, mpg, wt, hp)
  })
}

shinyApp(ui, server)
