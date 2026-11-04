# ------------------------------------------------------------
# App:        abhall_app2.R
# Author:     Abby Hall
# Started from: starter-apps/app-basic6.R
# What I changed:
#   -
#   - 
# Feature
#   - Tate: added a bill-depth range slider for the plot and table.
# ------------------------------------------------------------

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
      # Feature range slider
      sliderInput("bill_depth",
                  "Set bill depth range",
                  min = 13.1,
                  max = 21.5,
                  value = c(13.1, 15)),
      selectInput("sex",
                  "Choose sex",
                  choices = c("male","female"),
                  selected = "female"),
    selectInput("species",
            "Choose species",
            choices = c("Adelie", "Chinstrap", "Gentoo"),
            selected = "Adelie")
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
                   between(bill_depth_mm, input$bill_depth[1], input$bill_depth[2]),
                   sex == input$sex,
                  species == input$species), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species) 
    # fig <- fig %>% layout(scene =
    #                         list(xaxis = list(title = 'Body Mass'),
    #                              yaxis = list(title = 'Bill Length'),
    #                              zaxis = list(title = 'Flipper Length')))
  })
  
  output$table <- renderTable({
    mydata <- filter(penguins,between(bill_depth_mm, input$bill_depth[1], input$bill_depth[2]),sex == input$sex,species == input$species) |> arrange(desc(body_mass_g))
    tibble(body_mass = mydata$body_mass_g, bill_length = mydata$bill_length_mm, flipper_length = mydata$flipper_length_mm, species = mydata$species)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

