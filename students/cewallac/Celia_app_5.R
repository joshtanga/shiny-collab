# App:      Celia_app_5.R
# Author:   Celia Wallace 
# Started from: starter-apps/app-basic4.R
#What I changed: 
# - Fundamental Change: I added two values using a collection. 
# - Changed color to be based on body mass instead of species. 
# - Changed the auto select to male instead of female. 
# - Changed maximum to 30.

library(plotly)
library(palmerpenguins)



# level 4 complexity
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Filtering bill depth with slider with plotly"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bill_depth",
                  "Set bill depth",
                  min = 13.1,
                  max = 30.0,
                  value = c(15,20)),
      selectInput("sex",
                  "Choose sex",
                  choices = c("male","female"),
                  selected = "male")
    ),
    
    mainPanel(
      plotlyOutput("graph"),
      tableOutput("table")
    )
  )
)


server <- function(input, output) {
  
  output$graph <- renderPlotly({
    
    # filter within the plot_ly call is ok
    plot_ly(filter(penguins,
                   bill_depth_mm < input$bill_depth,
                   sex == input$sex), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~body_mass_g) 
    # fig <- fig %>% layout(scene =
    #                         list(xaxis = list(title = 'Body Mass'),
    #                              yaxis = list(title = 'Bill Length'),
    #                              zaxis = list(title = 'Flipper Length')))
  })
  
  output$table <- renderTable({
    mydata <- filter(penguins,bill_depth_mm < input$bill_depth,sex == input$sex) |> arrange(desc(body_mass_g))
    tibble(body_mass = mydata$body_mass_g, bill_length = mydata$bill_length_mm, flipper_length = mydata$flipper_length_mm, species = mydata$species)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

