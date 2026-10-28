
# ------------------------------------------------------------
# App:        lrhoades_app1.R
# Author:     Lyle Rhoades
# Started from: Provided penguin Shiny starter app
# What I changed:
#   - added a selectInput for penguin species
#   - added axis labels to the 3D Plotly graph
# ------------------------------------------------------------

library(plotly)
library(palmerpenguins)
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Filtering Bill Depth with Plotly"),

  sidebarLayout(
    sidebarPanel(
      sliderInput("bill_depth",
                  "Set bill depth",
                  min = 13.1,
                  max = 21.5,
                  value = 15),

      selectInput("sex",
                  "Choose sex",
                  choices = c("male", "female"),
                  selected = "female"),

      # New species dropdown
      selectInput("species",
                  "Choose species",
                  choices = c("All", "Adelie", "Chinstrap", "Gentoo"),
                  selected = "All")
    ),

    mainPanel(
      plotlyOutput("graph"),
      tableOutput("table")
    )
  )
)

server <- function(input, output) {

  output$graph <- renderPlotly({

    plot_ly(
      filter(penguins,
             bill_depth_mm < input$bill_depth,
             sex == input$sex,
             input$species == "All" | species == input$species),
      x = ~body_mass_g,
      y = ~bill_length_mm,
      z = ~flipper_length_mm,
      color = ~species,
      type = "scatter3d",
      mode = "markers"
    ) |>
      layout(
        scene = list(
          xaxis = list(title = "Body Mass (g)"),
          yaxis = list(title = "Bill Length (mm)"),
          zaxis = list(title = "Flipper Length (mm)")
        )
      )
  })

  output$table <- renderTable({

    mydata <- filter(
      penguins,
      bill_depth_mm < input$bill_depth,
      sex == input$sex,
      input$species == "All" | species == input$species
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
