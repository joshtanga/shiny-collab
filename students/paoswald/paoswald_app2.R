# ------------------------------------------------------------
# App:        paoswald_app2.R
# Author:     Patton Osald
# Started from: starter-apps/app-basic2.R
# What I changed:
#   - I added a dropdown to chose between x^2 and x^3
#   - I updated graph to show the specific function
#   - I also updated the table to calculate the function
# ------------------------------------------------------------
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Graph of a function"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("x",
                  "Current x-coordinate",
                  min = -100,
                  max = 100,
                  value = 30),
    selectInput("function_type",
      "Choose a function",
      choices = c("x^2", "x^3"))
    ),
    
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

    # reactive part -- i.e., updates when input$x changes
    # Converts the graph to .html * makes it reactive
    output$graph <- renderPlot({

        if (input$function_type == "x^2") {
          df <- tibble(x_val = X, y_val = X^2)
          y <- input$x^2
        }
        else {
          df <- tibble(x_val = X, y_val = X^3)
          y <- input$x^3
        }

        ggplot(df,aes(x=x_val,y=y_val)) + geom_line() +
          geom_point(aes(x=input$x,y=y), size = 20) + 
          geom_point(aes(x=input$x,y=y), size = 10,
                     color = "white")
        })
  
    # Converts the table to .html * makes it reactive
    output$table <- renderTable({
      if (input$function_type == "x^2") {
        tibble(x = input$x, y = input$x^2)
      }
      else {
        tibble(x = input$x, y = input$x^3)
      }
      })
}

# Run the application 
shinyApp(ui = ui, server = server)
