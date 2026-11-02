library(plotly)
library(bslib)

# ------------------------------------------------------------
# App:        cbentley_app2.R
# Author:     Caity Bentley
# Started from: starter-apps/app-basic4.R
# What I changed:
#   - swapped penguins for iris data
# 


# level 4 complexity
library(shiny)
library(tidyverse)

ui <- page_fluid(
  titlePanel("Filtering petal length with slider with plotly"),
  sidebarLayout(
    sidebarPanel(
      # syntax for slider input: sliderInput(inputId, label, min, max, value)
      sliderInput("Petal.Length",
                  "Set petal length",
                  min = 1.0,
                  max = 7.0,
                  value = 3.75)
   ),
    
    # Show a plot of the generated distribution
    mainPanel(
      # --
      # --  
      # --  -- -- -- notice this is plotlyOutput, not plotOutput
      # --
      # --  
      plotlyOutput("graph"),
    )
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

