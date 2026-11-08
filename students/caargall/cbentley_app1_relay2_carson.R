# ------------------------------------------------------------
# App:cbentley_app1.R
# Author: Caity Bentley
# Started from: starter-apps/app-basic6.R
# What I changed:
#   - added a table showing number of penguins from each species
#     that reacts to the slider
# ------------------------------------------------------------

library(plotly)
library(palmerpenguins)




# level 4 complexity
library(shiny)
library(tidyverse)
library(bslib)


ui <- page_fluid(
  theme = bs_theme(bootswatch = "flatly"),
  titlePanel("Comparing the sexes bill depth using proximity: plotly"),
  sidebarLayout(
    sidebarPanel(
      input_dark_mode(),
      p("Make Selections to filter the data shown in the plot", style = "font-size:8pt"),
      sliderInput("bill_depth",
                  "Set bill depth",
                  min = 13.1,
                  max = 21.5,
                  value = c(13.1, 21.5)),
      selectInput("sex",
                  "Choose sex",
                  choices = c("male", "female"),
                  selected = "female")
    ),
    mainPanel(
      p("This page has: One Range Slider, One Select, One Table, One Plotly Graph, and a Text Description",
        style = "font-size:10pt"),
      plotlyOutput("graph"),
      h4("Selected Range:"),
      verbatimTextOutput("selected_range"),
      h4("Selected One:"),
      verbatimTextOutput("selected_min"),
      tableOutput("table")
    )
  )
)

server <- function(input, output) {

  # reactive filtered data, shared by the plot and table
  filtered <- reactive({
    penguins |>
      filter(bill_depth_mm >= input$bill_depth[1],
             bill_depth_mm <= input$bill_depth[2],
             sex == input$sex)
  })

  output$selected_range <- renderPrint({
    input$bill_depth
  })

  output$selected_min <- renderPrint({
    input$bill_depth[1]
  })

  output$graph <- renderPlotly({
    plot_ly(filtered(),
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species,
            type = "scatter3d",
            mode = "markers") |>
      layout(scene = list(
        xaxis = list(title = "Body Mass"),
        yaxis = list(title = "Bill Length"),
        zaxis = list(title = "Flipper Length")
      ))
  })

  output$table <- renderTable({
    filtered() |>
      count(species, name = "Number of penguins")
  })
}

# Run the application
shinyApp(ui = ui, server = server)