
# ------------------------------------------------------------
# App:        lrhoades_app1.R
# Author:     Lyle Rhoades
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - changed the graph colors
#   - added text showing the selected x and y values
# ------------------------------------------------------------

library(shiny)
library(bslib)
library(tidyverse)

ui <- page_fluid(
  titlePanel("Evaluating a Function at a Parameter"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("x",
                  "Current x-coordinate",
                  min = -100,
                  max = 100,
                  value = 30)
    ),

    mainPanel(
      plotOutput("myplot"),
      textOutput("point_text")
    )
  )
)

# Define server function
server <- function(input, output) {

  X <- c(-100:100)
  df <- tibble(x_val = X, y_val = X^2)

  output$myplot <- renderPlot({

    y <- input$x^2

    ggplot(df, aes(x = x_val, y = y_val)) +
      geom_line(color = "blue") +
      geom_point(aes(x = input$x, y = y),
                 color = "red", size = 5)
  })

  # Display the selected coordinates
  output$point_text <- renderText({
    paste("Selected Point: X =", input$x,
          "Y =", input$x^2)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
