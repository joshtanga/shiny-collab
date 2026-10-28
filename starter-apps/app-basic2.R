# level 2 complexity
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
                  value = 30)
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
    df <- tibble(x_val=X,y_val=X^2)

    # reactive part -- i.e., updates when input$x changes
    # Converts the graph to .html * makes it reactive
    output$graph <- renderPlot({
        y    <- input$x^2
        ggplot(df,aes(x=x_val,y=y_val)) + geom_line() +
          geom_point(aes(x=input$x,y=y), size = 20) + 
          geom_point(aes(x=input$x,y=y), size = 10,
                     color = "white")
    })
  
    # Converts the table to .html * makes it reactive
    output$table <- renderTable({
      tibble(x = input$x, y = (input$x)^2)
      })
}

# Run the application 
shinyApp(ui = ui, server = server)
