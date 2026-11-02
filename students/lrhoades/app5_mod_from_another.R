#------------------------------------------------------------
# App:        app5_mod_from_another.R
# Author:     Lyle Rhoades
# Started from: starter-apps/app-basic5.R
# What was changed:
#   - Added a reset button for filters
# What I added was 
#   - Select input for Speices of penguins
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
      selectInput("species",
                  "Choose species",
                  choices = c("All", "Adelie", "Chinstrap", "Gentoo"),
                  selected = "All"),
  # ⬇️ PUT IT HERE ⬇️
  hr(), 
  actionButton("reset_btn", "Reset Filters")
    ),
    mainPanel(
      plotlyOutput("graph"),
      tableOutput("table")
    )
  )
)


server <- function(input, output, session) {
  
  output$graph <- renderPlotly({
    
    # filter within the plot_ly call is ok
    plot_ly(filter(penguins,
                   bill_depth_mm < input$bill_depth,
                   sex == input$sex), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species) 
    # fig <- fig %>% layout(scene =
    #                         list(xaxis = list(title = 'Body Mass'),
    #                              yaxis = list(title = 'Bill Length'),
    #                              zaxis = list(title = 'Flipper Length')))
  })
  
     # FEATURE: Listen for the reset button click
  observeEvent(input$reset_btn, {
    updateSliderInput(session, "bill_depth", value = 15)
    updateSelectInput(session, "sex", selected = "female")
  })

  output$table <- renderTable({
    mydata <- filter(penguins,bill_depth_mm < input$bill_depth,sex == input$sex) |> arrange(desc(body_mass_g))
    tibble(body_mass = mydata$body_mass_g, bill_length = mydata$bill_length_mm, flipper_length = mydata$flipper_length_mm, species = mydata$species)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

