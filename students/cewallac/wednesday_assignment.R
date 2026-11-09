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



    # ui
    numericInput("bill_depth", "Give me a bill depth max", value = 15, min = 13, max = 27), 
    # end of first card

      # change mainPanel to card and fix parenthesis
      card(
        plotlyOutput("graph")
      ) # end of second card
  ) # end of layout_column_wrap
) # end of page_fillable

)

server <- function(input, output) {
  output$graph <- renderPlotly({

    df <- reactive(
      filter(penguins,bill_depth_mm < input$bill_depth)
    )
    
    # only plot if df() exists
    if ((!is.null(df())))
    {
    plot_ly(df(), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species) |> 
        layout(scene =
               list(xaxis = list(title = 'Body Mass'),
                    yaxis = list(title = 'Bill Length'),
                    zaxis = list(title = 'Flipper Length')))
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

