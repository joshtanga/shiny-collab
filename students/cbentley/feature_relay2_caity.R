# App:      Celia_app_5.R
# Author:   Celia Wallace 
# Started from: starter-apps/app-basic4.R
#What I changed: 
# - Fundamental Change: I added two values using a collection. 
# - Changed color to be based on body mass instead of species. 
# - Changed the auto select to male instead of female. 
# - Changed maximum to 30.

# Feature Relay 

# Round 1: Plot click and Near points: Is not compatible with plotly and data is not reactive.
# I could not find a way to make the data work. 

# Round 2: DT table: DToutput. I used this code to filter and sort the original table into pages
# so that it is easier to view. This code also worked well with the original app, and was a good fit
# because the table on the app was very large. 

# Feature Relay 2 *I used my app I created in the first 
# feature relay to do the second relay

# Round 1: plotly hover: ggplot. I used this code by combining it with the plotly graph that was already
# created in this app. Instead of adding a new output$p plotly graph, I just added the hover info (using
# species) to the exisiting plotly graph. Now, when you hover over points on the graph it tells you what 
# species it is. 

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
      tableOutput("table"),
      DT::DTOutput("tbl"),
      plotly::plotlyOutput("p")
    )
  )
)


server <- function(input, output) {
  
  output$graph <- renderPlotly({
    plot_ly(filter(penguins,
                   bill_depth_mm < input$bill_depth,
                   sex == input$sex), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~body_mass_g) 
  })

    output$graph <- renderPlotly({
    plot_ly(filter(penguins,
                   bill_depth_mm < input$bill_depth,
                   sex == input$sex), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~body_mass_g,
            text = ~species,
            hoverinfo = "text")
  })
  
  output$table <- renderTable({
    mydata <- filter(penguins,bill_depth_mm < input$bill_depth,sex == input$sex) |> arrange(desc(body_mass_g))
    tibble(body_mass = mydata$body_mass_g, bill_length = mydata$bill_length_mm, flipper_length = mydata$flipper_length_mm, species = mydata$species)
  })
  output$tbl <- DT::renderDT(filter(penguins, bill_depth_mm < input$bill_depth, sex == input$sex))

}

# Run the application 
shinyApp(ui = ui, server = server)

