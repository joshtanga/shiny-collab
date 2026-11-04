# level 2 complexity
library(shiny)
library(tidyverse)
library(bslib)

# Changed titlePanel "Fuel Efficiency of Cars" to "Car MPG Comparison" 
# Changed minimum value reported on the graph from 20 MPG to 25 MPG
# Changed the graph title from "MPG and Car Weight" to "How Car Weight Affects Fuel Efficiency"
# Adder colors for plot results wher automatic = blue and manual = red

# Prepare the data
cars <- mtcars |>
  rownames_to_column("car") |>
  mutate(
    trans = if_else(am == 0, "Automatic", "Manual")
  )

# Create the app layout
ui <- page_fluid(
  titlePanel("Car MPG Comparison"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "mpg",
        "Minimum MPG:",
        min = floor(min(cars$mpg)),
        max = ceiling(max(cars$mpg)),
        value = 25
      )
    ),
    mainPanel(
      plotOutput("plot"),
      tableOutput("table")
    )
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
        title = "How Car Weight Affects Fuel Efficiency",
        subtitle = paste("Minimum MPG:", input$mpg),
        x = "Weight",
        y = "Miles per gallon",
        color = "Transmission"
      ) +
      scale_color_manual(values = c("Automatic" = "blue",
                                    "Manual" = "red"))
  })
  
  # Create the table
  output$table <- renderTable({
    data() |>
      select(car, mpg, wt, hp, cyl, trans)
  })
}

# Run the app
shinyApp(ui = ui, server = server)

