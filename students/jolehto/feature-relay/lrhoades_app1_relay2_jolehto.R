
# ------------------------------------------------------------
# App:        lrhoades_app1_relay2_jolehto.R
# Original Author:     Lyle Rhoades
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - used numericInput to determine how many values to display
# ------------------------------------------------------------

library(shiny)
library(bslib)
library(tidyverse)

ui <- page_fluid(
  titlePanel("Evaluating a Function at a Parameter"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "x",
        "Current x-coordinate",
        min = -100,
        max = 100,
        value = 30
      ),
      numericInput(
        "top_n",
        "How many values would you like to plot?",
        value = 30
      )
    ),

    mainPanel(
      plotOutput("myplot"),
      textOutput("point_text")
    )
  )
)

# Define server function
server <- function(input, output) {

  output$myplot <- renderPlot({

    high = input$top_n / 2
    low = -high

    X <- c(low:high)
    df <- tibble(x_val = X, y_val = X^2)

    y <- input$x^2

    df |>
      ggplot(aes(x = x_val, y = y_val)) +
      geom_line(color = "blue") +
      annotate("point", x = input$x, y = input$x^2, color = "red", size = 5) +
      coord_cartesian(xlim = c(low, high), ylim = c(0, 2500))
  })

  # Display the selected coordinates
  output$point_text <- renderText({
    paste("Selected Point: X =", input$x,
          "Y =", input$x^2)
  })

}

# Run the application
shinyApp(ui = ui, server = server)
