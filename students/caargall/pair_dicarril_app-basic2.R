# ------------------------------------------------------------
# App:        pair_dicarril_app-basic.R
# Author:     Carson Argall
# Started from: students/dicarril/dicarril_app-basic2.R
# What I changed:
#   - Added Cards
# 

# level 2 complexity
library(shiny)
library(tidyverse)
library(bslib)

# Prepare the data
cars <- mtcars |>
  rownames_to_column("car") |>
  mutate(
    trans = if_else(am == 0, "Automatic", "Manual")
  )

# Create the app layout
ui <- page_fillable(
  titlePanel("Fuel Efficiency of Cars"),

  layout_column_wrap(
    width = 1/2,

    card(
      card_header("Fuel Efficiency of Cars"),
      sliderInput(
        "mpg",
        "Minimum MPG:",
        min = floor(min(cars$mpg)),
        max = ceiling(max(cars$mpg)),
        value = 20
      )

    ),

    card(plotOutput("plot")),
    )
)
  

# Create the server
server <- function(input, output) {
  
  # Filter cars using the slider
  data <- reactive({
    cars |>
      filter(mpg >= input$mpg)
  })
  
  # Create the graph
  output$plot <- renderPlot({
    ggplot(data(), aes(x = wt, y = mpg, color = trans)) +
      geom_point(size = 4) +
      labs(
        title = "MPG and Car Weight",
        subtitle = paste("Minimum MPG:", input$mpg),
        x = "Weight",
        y = "Miles per gallon",
        color = "Transmission"
      ) +
      theme_minimal()
  })
  
  # Create the table
  output$table <- renderTable({
    data() |>
      select(car, mpg, wt, hp, cyl, trans)
  })
}

# Run the app
shinyApp(ui = ui, server = server)

