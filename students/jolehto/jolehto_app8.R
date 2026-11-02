# --------------------------------------------------------------------------------------------------
# App: jolehto_app8.R
# Author: Joshua Lehto
# Started from: starter-apps/app-basic8.R
# What I changed:
# > tidied up the code
# > 2d plot of storms instead of 3d plot of penguins
# > ggplot instead of plotly
# > added a second input in the first card
# > used scale_fill_manual to ensure colors stayed consistent
# > used coord_cartesian to ensure graph dimensions stayed the same
# What could be better:
# > styling
# > better colors
# --------------------------------------------------------------------------------------------------

library(plotly)
library(bslib)
library(shiny)
library(tidyverse)


ui <- page_fillable(

  titlePanel("Visualizing Storms with RShiny"),

  layout_column_wrap(
    width = 1/2,

    # Card 1
    card(
      card_header("Storms by year with Plotly"),
      sliderInput(
        "year",
        "Year",
        min = min(storms$year, na.rm=TRUE),
        max = max(storms$year, na.rm=TRUE),
        value = mean(storms$year, na.rm=TRUE),
        step = 1
      ),
      
      sliderInput(
        "window",
        "Year window",
        min = 1,
        value = 5,
        max = 10,
        step = 1
      )
    ),

    # Card 2
    card(
      plotlyOutput("graph")
    )
  )
)

server <- function(input, output) {
  
  output$graph <- renderPlotly({
    
    storms |>
      # Data
      filter(
        abs(year - input$year) < input$window
      ) |>
      # Plot
      ggplot(aes(x=wind, y=pressure, color=status)) +
      geom_point() +
      coord_cartesian(
        xlim = c(min(storms$wind, na.rm=TRUE), max(storms$wind, na.rm=TRUE)),
        ylim = c(min(storms$pressure, na.rm=TRUE), max(storms$pressure, na.rm=TRUE))
      ) +
      # Labels
      labs(
        x = "Wind",
        y = "Pressure",
        color = "Status"
      ) +
      scale_color_manual( # keep status colors consistent
        values = c( # https://colorbrewer2.org
          "tropical depression" = '#8dd3c7', 
          "tropical storm" = '#ffffb3',
          "extratropical" = '#bebada',
          "hurricane" = '#fb8072',
          "subtropical storm" = '#80b1d3',
          "subtropical depression" = '#fdb462',
          "disturbance" = '#b3de69',
          "other low" = '#fccde5',
          "tropical wave" = '#d9d9d9'
        )
      )

  })
}

# Run the application 
shinyApp(ui = ui, server = server)