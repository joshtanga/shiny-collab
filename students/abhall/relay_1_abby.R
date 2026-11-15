# ------------------------------------------------------------
# App:        caargall_app4.R
# Author:     Carson Argall
# Started from: starter-apps/app-basic4.R
# What I changed:
#   - changed from penguins to mtcars
#   - changed sliderInput to mpg
#   - added outputTable to show mpg and qsec of selected
#   - added selectInput to choose whether you want to use weight or qsec as y value
# ------------------------------------------------------------

# Relay round: 1
# Started from: students/caargall/app4.R
# Cards drawn: Plot brush + brushedpoints()
# Added: 

library(plotly)
library(palmerpenguins)
library(bslib)



# level 4 complexity
library(shiny)
library(tidyverse)

ui <- page_fluid(
  titlePanel("Filtering mpg depth compared to qsec, and weight"),
  sidebarLayout(
    sidebarPanel(
      # syntax for slider input: sliderInput(inputId, label, min, max, value)
      sliderInput("mpg",
                  "Set mpg",
                  min = 10,
                  max = 35,
                  value = 10),
      selectInput("yVariable",
                  "Choose y value",
                  choices = c("qsec", "wt"),
                  selected = "qsec")
   ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("graph", brush="plot_brush"),
      tableOutput("table"),
    )
  )
)


server <- function(input, output) {

  newmtcars <- mtcars |>
    rownames_to_column(var = "name")

 
  output$graph <- renderPlot({
    ggplot(
      data = filter(newmtcars, mpg >= input$mpg),
      aes(
        x = mpg,
        y = .data[[input$yVariable]]
      )
    ) +
      geom_point()
  })

  
  output$table <- renderTable({

    df <- filter(newmtcars, mpg >= input$mpg) |>
      select(name, mpg, qsec, wt)

    brushedPoints(df, input$plot_brush, xvar="mpg", yvar=input$yVariable)

  })

}

# Run the application
shinyApp(ui = ui, server = server)

  