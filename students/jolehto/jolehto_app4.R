# --------------------------------------------------------------------------------------------------
# App: jolehto_app4.R
# Author: Joshua Lehto
# Started from: starter-apps/app-basic4.R
# What I changed:
# > tidied up the code
# > changed title and axis labels
# > removed both figs and made plot with one pipeline
# > gave the min, middle, and max of sliderInput a relevant function instead of a set value
# > gave plot_ly a `type` and `mode` to get rid of warnings
# > filter data within a window, rather than everything below a slider value
# What could be better:
# > styling
# --------------------------------------------------------------------------------------------------

# Library
library(tidyverse)
library(plotly)
library(palmerpenguins)
library(bslib)
library(shiny)

ui <- page_fluid(
  titlePanel("Penguin Morphological given Bill Depth"),
  sidebarLayout(
    # Sidebar Panel
    sidebarPanel(
      # sliderInput(inputId, label, min, max, value)
      sliderInput( 
        "bill_depth",
        "Bill depth (mm)",
        min = min(penguins$bill_depth_mm, na.rm = TRUE),
        max = max(penguins$bill_depth_mm, na.rm = TRUE),
        value = mean(penguins$bill_depth_mm, na.rm = TRUE)
      ),
      # Bill Depth Window
      sliderInput(
        "window",
        "Bill depth window",
        min = 0.1,
        max = 10,
        value = 1
      )
    ),
    # Show a plot of the generated distribution
    mainPanel(
      # Use plotlyOutput, not plotOutput!
      plotlyOutput("graph"), 
    )
  )
)

server <- function(input, output) {

  # Use plot_ly function to create 3D scatter plot
  output$graph <- renderPlotly(

    # plot_ly(data, x=~, y=~, z=~, color=~)
    penguins |>
      # Data
      filter(
        abs(bill_depth_mm - input$bill_depth) <= input$window
      ) |>
      # Plot
      plot_ly(
        type = "scatter3d",
        mode = "markers",
        x = ~body_mass_g,
        y = ~bill_length_mm,
        z = ~flipper_length_mm,
        color = ~species
      ) |>
      # Axis labeling
      layout(
        scene = list(
          xaxis = list(title = 'Body Mass (g)'),
          yaxis = list(title = 'Bill Length (mm)'),
          zaxis = list(title = 'Flipper Length (mm)')
        )
      )
  )
}

# Run the application 
shinyApp(ui = ui, server = server)