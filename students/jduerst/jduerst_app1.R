# ------------------------------------------------------------
# App:        jduerst_app1.R
# Author:     Janson Duerst
# Started from: starter-apps/app-basic8.R
# What I changed:
# Changed dataset to mpg
# Changed colors
# ------------------------------------------------------------

library(plotly)
library(bslib)
library(shiny)
library(scales)
library(tidyverse)


ui <- page_fillable(

  titlePanel("Demonstration of using cards() to control layout in RShiny"),
  h6('Janson Duerst'),

  layout_column_wrap(

    width = 1/2,

    # first card
    card(
      # change titlePanel to card_header and put it in a card()
      card_header("Filtering Number of Cylinders"),

      # kill sidebarLayout & sidebarPanel
      sliderInput("cyl",
                    "Number of Cylinders",
                    min = 4,
                    max = 8,
                    value = 6)
      ), # end of first card

      # change mainPanel to card and fix parenthesis
      card(
        plotlyOutput("graph")
      ) # end of second card
  ) # end of layout_column_wrap
) # end of page_fillable



server <- function(input, output) {
  
  output$graph <- renderPlotly({

    plot_ly(filter(mpg,cyl == input$cyl), 
            x = ~cty,
            y = ~hwy,
            z = ~displ,
            color = ~class,
            # Changing colors (viridis has 5 pallette options, D is default)
            colors = viridis_pal(option = "A")(7)) |> 
        layout(scene =
               list(xaxis = list(title = 'City mpg'),
                    yaxis = list(title = 'Highway mpg'),
                    zaxis = list(title = 'Engine Displacement (L)')))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

