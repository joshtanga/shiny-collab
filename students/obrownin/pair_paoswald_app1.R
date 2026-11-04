
# ------------------------------------------------------------
# App:        pair_paoswald_app1.R
# Original author: Patton Oswald  (students/paoswald/paoswald_app1.R)
# Pair-modified by: Olivia Browning
# What I changed:
#   - added cards to the ui
#   - removed unused slider tables
# ------------------------------------------------------------
library(plotly)
  library(palmerpenguins)



  # level 4 complexity
  library(shiny)
  library(tidyverse)
  library(bslib)

  ui <- page_fluid(
    titlePanel("Penguin Bill Measurements"),

    card(
      # change titlePanel to card_header and put it in a card()
      card_header("Filtering bill depth with slider with plotly"),
        sliderInput("bill_depth",
                    "Set bill depth",
                    min = 13.1,
                    max = 21.5,
                    value = 15),
        selectInput("sex",
                    "Choose sex",
                    choices = c("male","female"),
                    selected = "female"),
        selectInput("species",
                    "Choose Penguin Species",
                    choices =c("Adelie", "Chinstrap", "Gentoo")
        )
      ),
      
      card(
        plotlyOutput("graph"),
        tableOutput("table"))
    )
  


  server <- function(input, output) {
    
    output$graph <- renderPlotly({
      
      # filter within the plot_ly call is ok
      plot_ly(filter(penguins,
                    bill_depth_mm < input$bill_depth,
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
      mydata <- filter(penguins,
        bill_depth_mm < input$bill_depth,
        species == input$species,
        sex == input$sex) |> 
        arrange(desc(body_mass_g))
      tibble(body_mass = mydata$body_mass_g, bill_length = mydata$bill_length_mm, flipper_length = mydata$flipper_length_mm, species = mydata$species)
    })
  }

  # Run the application 
  shinyApp(ui = ui, server = server)

