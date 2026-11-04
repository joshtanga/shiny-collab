#------------------------------------------------------------
# App:        obrownin_app5.R
# Author:     Olivia Browning
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - Added a reset button for filters
# Feature Relay
# I added the checkboxGroupInput() this one because i felt it applyied well if you wanted
# to compare all 3 speices of penguins or one or two it fit well
# One that could be added was the radioButtons() to show what the percent of the data
# is each species would be cool
# ------------------------------------------------------------


library(plotly)
library(palmerpenguins)



# level 4 complexity
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Filtering bill depth with slider with plotly"),
  checkboxGroupInput("sp", "Species",
    choices = levels(penguins$species),
    selected = levels(penguins$species)),
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
                   species %in% input$sp, bill_depth_mm < input$bill_depth,
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

