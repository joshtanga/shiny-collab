# ------------------------------------------------------------
# App:        caargall_app5.R
# Author:     Carson Argall
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - Added checkboxes to choose species
#   - Added renderText() to show what species is selected
# ------------------------------------------------------------

# Relay round: 2
# Started from: students/caargall/app5.R
# Cards drawn: Plot brush + brushedpoints()
# Added: -ggplot and geom_point to be able to use this feature
#        -added a brushed points
#        - changed y variable to make it usuable in ggplot instead of plotly

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
      textOutput("summary")
    )
  )
)


server <- function(input, output) {

  filtered <- reactive({
    filter(penguins,
           bill_depth_mm < input$bill_depth,
           sex == input$sex,
           species %in% input$species)
  })

  output$graph <- renderPlotly({

    plot_ly(filtered(),
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species)

  })
  
  
  output$speciesSelected <- renderText({
    paste("Species Selected: ", paste(input$species, collapse = ", "))
  })

  output$table <- renderTable({
    mydata <- filtered() |>
      arrange(desc(body_mass_g))
  })

  output$summary <- renderText({

    str_c(
      "Showing ", nrow(filtered()), " of ", nrow(penguins),
      " rows; mean bill length = ",
      round(mean(filtered()$bill_length_mm, na.rm = TRUE), 1),
      " mm"
    )

  })

  
}

# Run the application 
shinyApp(ui = ui, server = server)

