# ------------------------------------------------------------
# App:        racbrown_app9.R
# Author:     Rachel Brown
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - swapped the y = x^2 curve for the mpg (fuel economy) dataset
#   - added radioButtons so the user can choose highway or city mpg
#   - added a renderText output that summarizes the cars shown
# ------------------------------------------------------------

library(shiny)
library(bslib)
library(tidyverse)

ui <- page_fluid(
  titlePanel("Engine Size and Fuel Economy"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("min_displ",
                  "Minimum engine size (liters)",
                  min = 1.6,
                  max = 7,
                  value = 1.6,
                  step = 0.1),
      radioButtons("mpg_type",
                   "Mileage type",
                   choices = c("Highway" = "hwy", "City" = "cty"),
                   selected = "hwy")
    ),
    mainPanel(
      plotOutput("myplot"),
      textOutput("summary_text")
    )
  )
)

server <- function(input, output) {
  output$myplot <- renderPlot({
    d <- mpg |> filter(displ >= input$min_displ)

    ggplot(d, aes(x = displ, y = .data[[input$mpg_type]], color = class)) +
      geom_point(size = 3, alpha = 0.8) +
      labs(x = "Engine size (liters)",
           y = ifelse(input$mpg_type == "hwy",
                      "Highway miles per gallon",
                      "City miles per gallon"),
           color = "Vehicle class")
  })

  output$summary_text <- renderText({
    d <- mpg |> filter(displ >= input$min_displ)
    paste0("Showing ", nrow(d), " cars. Average ",
           ifelse(input$mpg_type == "hwy", "highway", "city"),
           " mileage: ", round(mean(d[[input$mpg_type]]), 1), " mpg.")
  })
}

shinyApp(ui = ui, server = server)