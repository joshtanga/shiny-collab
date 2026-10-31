# ------------------------------------------------------------
# App:        jduerst_app1.R
# Author:     Janson Duerst
# Started from: starter-apps/app-basic8.R
# What I changed:
#
# ------------------------------------------------------------

library(plotly)
library(palmerpenguins)
library(bslib)
library(shiny)
library(tidyverse)


ui <- page_fillable(

  titlePanel("Demonstration of using cards() to control layout in RShiny"),

  layout_column_wrap(

    width = 1/2,

    # first card
    card(
      # change titlePanel to card_header and put it in a card()
      card_header("Filtering bill depth with slider with plotly"),

      # kill sidebarLayout & sidebarPanel
      sliderInput("bill_depth",
                    "Set bill depth",
                    min = 13.1,
                    max = 21.5,
                    value = 15)
      ), # end of first card

      # change mainPanel to card and fix parenthesis
      card(
        plotlyOutput("graph")
      ) # end of second card
  ) # end of layout_column_wrap
) # end of page_fillable



server <- function(input, output) {
  
  output$graph <- renderPlotly({
    
    plot_ly(filter(penguins,bill_depth_mm < input$bill_depth), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species) |> 
        layout(scene =
               list(xaxis = list(title = 'Body Mass'),
                    yaxis = list(title = 'Bill Length'),
                    zaxis = list(title = 'Flipper Length')))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

