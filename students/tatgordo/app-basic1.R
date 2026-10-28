library(shiny)
library(bslib) # for page_* functions 
library(tidyverse)

# Data that is not reactive can be defined here
# Define the range of x values
X <- c(-100:100)
df <- tibble(x_val=X,y_val=X^2)

ui <- page_fluid(
  titlePanel("Evaluating a Function at a Parameter"), # App title
  sidebarLayout( # Sidebar + Main panel layout
    # Sidebar with a slider input for x-coordinate
    sidebarPanel(
      # slider for selecting x value
      sliderInput("x",
                  "Current x-coordinate",
                  min = -100,
                  max = 100,
                  value = 30)
    ),
    
    # Show a plot of the graph of y = x^2
    mainPanel(
      plotOutput("myplot")
    )
  )
)


# Define server function  
server <- function(input, output) {

    # Anything inside output$... is reactive
    # -- Output to UI --
    output$myplot <- renderPlot({
        # input$x is the current x value from the slider
        y    <- input$x^2
        # plots the graph of y = x^2 and highlights the point (input$x, y)
        ggplot(df,aes(x=x_val,y=y_val)) + geom_line() +
          annotate("point", x = input$x, y = y, size = 20)
          # changed geom_point to annotate because geom_point was trying to draw
          # geom_point(aes(x=input$x,y=y), size = 20)

  })
}

# Run the application 
shinyApp(ui = ui, server = server)
