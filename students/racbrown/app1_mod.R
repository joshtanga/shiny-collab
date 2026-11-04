# ------------------------------------------------------------
# App:        <tatgordo>_app1.R
# Author:     <Tate Gordon>
# Started from: starter-apps/app-basic1.R
# What I changed:
#  - geom_point is being used to draw a point at where the current x value is according to x^2
#  - the problem with this is its taking in all 201 rows of data so in turn its drawing 201 points on top of eachother
#  - annotate is used to add single items like text or points to a plot
#  - annotate draws a single point at the current x value according to x^2 instead of 201 times
# ------------------------------------------------------------
#-------------------------------------------------------------
# App:        pair_<tatgordo>_app1.R
# Original Author:     <Tate Gordon>
# Pair-modified by : <Rachel Brown>
# Started from: starter-apps/app-basic1.R
# What I changed:
#    - Put the graph and slider on different cards
#    - Added a table and shows the x and y values
#    - Added different tabs for the information regarding the table
#------------------------------------------------------------------
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
    card(sidebarPanel(
      # slider for selecting x value
      sliderInput("x",
                  "Current x-coordinate",
                  min = -100,
                  max = 100,
                  value = 30))
    ),
    
    # Tabbed card in the main panel
    mainPanel(
      navset_card_tab(
        # Tab 1: the graph of y = x^2
        nav_panel("Plot", plotOutput("myplot")),
        # Tab 2: the current values of x and y
        nav_panel("Values", tableOutput("mytable")),
        # Tab 3: short description
        nav_panel("About",
                  p("This app graphs the function y = x\u00B2."),
                  p("Move the slider to choose an x-coordinate. The point on the",
                    "curve shows the function evaluated at that x."))
      )
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
          # changed geom_point to annotate because geom_point was drawing 201 dots in same spot
          # geom_point(aes(x=input$x,y=y), size = 20)

  })

    # Table showing the current x and y = x^2
    output$mytable <- renderTable({
        tibble(x = input$x, `y = x^2` = input$x^2)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)