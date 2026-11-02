# ------------------------------------------------------------
# App:        caargall_app5.R
# Author:     Carson Argall
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - Added checkboxes to choose species
#   - Added renderText() to show what species is selected
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
      sliderInput("bill_depth",
                  "Set bill depth",
                  min = 13.1,
                  max = 21.5,
                  value = 15),
      selectInput("sex",
                  "Choose sex",
                  choices = c("male","female"),
                  selected = "female"),
      checkboxGroupInput("species",
                         "Choose Species",
                        choices = c("Adelie", "Chinstrap", "Gentoo"),
                        selected = c("Adelie", "Chinstrap", "Gentoo"))
    ),
    
    mainPanel(
      plotlyOutput("graph"),
      tableOutput("table"),
      textOutput("speciesSelected")
    )
  )
)


server <- function(input, output) {
  
  output$graph <- renderPlotly({
    
    # filter within the plot_ly call is ok
    plot_ly(filter(penguins,
                   bill_depth_mm < input$bill_depth,
                   sex == input$sex,
                  species %in% input$species), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species) 
    # fig <- fig %>% layout(scene =
    #                         list(xaxis = list(title = 'Body Mass'),
    #                              yaxis = list(title = 'Bill Length'),
    #                              zaxis = list(title = 'Flipper Length')))
  })
  
  output$speciesSelected <- renderText({
    paste("Species Selected: ", paste(input$species, collapse = ", "))
  })

  output$table <- renderTable({
    mydata <- filter(penguins,bill_depth_mm < input$bill_depth,sex == input$sex, species %in% input$species) |> arrange(desc(body_mass_g))
    tibble(body_mass = mydata$body_mass_g, bill_length = mydata$bill_length_mm, flipper_length = mydata$flipper_length_mm, species = mydata$species)
  })

  
}

# Run the application 
shinyApp(ui = ui, server = server)

