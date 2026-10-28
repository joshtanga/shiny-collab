# ------------------------------------------------------------
# App:        <your-username>_app1.R
# Author:     <Your Name>
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - swapped penguins for gapminder
#   - added a selectInput for continent
#   - added a summary table that reacts to the slider
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
      sliderInput(
        "bill_depth",
        "Set bill depth",
        min = 13.1,
        max = 21.5,
        value = 15
      ),
      selectInput(
        "sex",
        "Choose sex",
        choices = c("male", "female"),
        selected = "female"
      )
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
    plot_ly(
      filter(penguins, bill_depth_mm < input$bill_depth, sex == input$sex),
      x = ~body_mass_g,
      y = ~bill_length_mm,
      z = ~flipper_length_mm,
      color = ~species
    )
    # fig <- fig %>% layout(scene =
    #                         list(xaxis = list(title = 'Body Mass'),
    #                              yaxis = list(title = 'Bill Length'),
    #                              zaxis = list(title = 'Flipper Length')))
  })

  output$table <- renderTable({
    mydata <- filter(
      penguins,
      bill_depth_mm < input$bill_depth,
      sex == input$sex
    ) |>
      arrange(desc(body_mass_g))
    tibble(
      body_mass = mydata$body_mass_g,
      bill_length = mydata$bill_length_mm,
      flipper_length = mydata$flipper_length_mm,
      species = mydata$species
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
