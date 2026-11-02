library(plotly)
library(bslib)

# ------------------------------------------------------------
# App:        pair_cbentley_app2.R
# Author:     Carson Argall
# Started from: students/cbentley/cbentley_app2.R
# What I changed:
#   - Added Cards
# 

# level 4 complexity
library(shiny)
library(tidyverse)

ui <- page_fillable(
  titlePanel("Filtering petal length with slider with plotly"),

  layout_column_wrap(
    width = 1/2,

    card(
      card_header("Filtering petal length with slider with plotly"),

      sliderInput("Petal.Length",
                  "Set petal length",
                  min = 1.0,
                  max = 7.0,
                  value = 3.75)
    ),

    card(plotlyOutput("graph")),
  )
)


server <- function(input, output) {

    # use plot_ly function to create 3D scatter plot
    output$graph <- renderPlotly({
      
    # syntax plot_ly(data, x=~, y=~, z=~, color=~)
     fig <- plot_ly(filter(iris, Petal.Length < input$Petal.Length), 
                       x = ~Petal.Width,
                       y = ~Sepal.Length,
                       z = ~Sepal.Width,
                       color = ~Species) 
     fig <- fig |> layout(scene =
                       list(xaxis = list(title = 'Petal Width'),
                            yaxis = list(title = 'Sepal Length'),
                            zaxis = list(title = 'Sepal Width')))
    })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

