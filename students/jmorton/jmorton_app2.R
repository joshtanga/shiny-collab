library(plotly)
library(palmerpenguins)
library(bslib)



# level 4 complexity
library(shiny)
library(tidyverse)

ui <- page_fluid(
  titlePanel("Filtering bill depth with slider with plotly"),
  sidebarLayout(
    sidebarPanel(
      # syntax for slider input: sliderInput(inputId, label, min, max, value)
      sliderInput("bill_depth",
                  "Set bill depth",
                  min = 13.1,
                  max = 21.5,
                  value = 15)
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
     fig <- plot_ly(filter(penguins,bill_depth_mm < input$bill_depth), 
                       x = ~body_mass_g,
                       y = ~bill_length_mm,
                       z = ~flipper_length_mm,
                       color = ~species) 
     fig <- fig |> layout(scene =
                       list(xaxis = list(title = 'Body Mass'),
                            yaxis = list(title = 'Bill Length'),
                            zaxis = list(title = 'Flipper Length')))
    })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

