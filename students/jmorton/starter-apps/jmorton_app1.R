# ------------------------------------------------------------
# App:        jmorton_app1.R
# Author:     Jett Morton
# Started from: starter-apps/app-basic2.R
# What I changed:
#   - changed slider in ui to select for colors
#   - added a color collection to server
#   - changed renderPlot() code so plot changes color based on slider position
# ------------------------------------------------------------

# level 2 complexity
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Graph of a function"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("color",
            "Select a color",
            min = 1,
            max = 5,
            value = 1,
            step = 1)),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("graph"), # displays the graph created below
      tableOutput("table") # displays the table created below
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
    # non-reactive part
    # Define the function & store the data
    X <- c(-100:100)
    df <- tibble(x_val=X,y_val=X^2)
  # Create a collection of 5 colors
colors <- c("red", "blue", "green", "purple", "orange")

    # reactive part -- i.e., updates when input$x changes
    # Converts the graph to .html * makes it reactive
    output$graph <- renderPlot({
        # Select a color based on the slider position
    selected_color <- colors[input$color]
        ggplot(df,aes(x=x_val,y=y_val)) + geom_line() +
          geom_point(size = 5, color = selected_color)
    })
  
    # Converts the table to .html * makes it reactive
    output$table <- renderTable({
      tibble(x = input$x, y = (input$x)^2)
      })
}

# Run the application 
shinyApp(ui = ui, server = server)
