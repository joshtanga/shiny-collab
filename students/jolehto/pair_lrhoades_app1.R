
# ------------------------------------------------------------
# App: pair_lrhoades_app1.R
# Original Author: Lyle Rhoades (students/lrhoades_app1.R)
# Pair-modified by: Joshua Lehto
# What I changed: 
# > you can now graph a cubic function w/ sliders for input
# > you can still get a value at a specific x coordinate
# > changed to card layout
# ------------------------------------------------------------

library(shiny)
library(bslib)
library(tidyverse)

ui_max = 10

ui <- page_fluid(
  titlePanel("Graphing a Cubic Function"),
  layout_column_wrap(
    width = 1/2,

    card(
      card_header("Input: x^3 + x^2 + x + C"),
      sliderInput(
        "x3",
        "x^3",
        min = -ui_max,
        max = ui_max,
        value = 0
      ),
      sliderInput(
        "x2",
        "x^2",
        min = -ui_max,
        max = ui_max,
        value = 0
      ),
      sliderInput(
        "x",
        "x",
        min = -ui_max,
        max = ui_max,
        value = 0
      ),
      sliderInput( # doesn't have much effect so make min and max greater
        "c",
        "C",
        min = -100,
        max = 100,
        value = 0
      )
    ),

    card(
      card_header("Output"),

      plotOutput("myplot"),

      sliderInput(
        "val",
        "Value at X Coordinate:",
        min = -25,
        max = 25,
        value = 0
      ),

      textOutput("point_text")
    )
  )
)

# Define server function
server <- function(input, output) {

  # calculate function
  calculate <- function(x_val) {
    y_val = ((x_val^3 * input$x3) + (x_val^2 * input$x2) + (x_val * input$x) + input$c)
    return(y_val)
  }

  # render plot
  output$myplot <- renderPlot({
    # Data
    X <- c(-25:25)
    df <- tibble(x_val = X, y_val = sapply(x_val, calculate))

    df |>
      # Plot
      ggplot(aes(x = x_val, y = y_val)) +
      geom_line(color = "steelblue2") +
      annotate("point", x=input$val, y=calculate(input$val), size = 5, color="orange") + #<- could probably be optimized (get data from df rather than calculating)
      # Labels
      labs(
        x = "X",
        y = "Y"
      ) +
      scale_y_continuous(labels = scales::label_number()) +
      coord_cartesian(ylim = c(-100,100))

  })

  # Display the selected coordinates
  output$point_text <- renderText({
    paste("Selected Point: X =", input$val,
          "Y =", calculate(input$val)) #<- could probably be optimized (same as above)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
