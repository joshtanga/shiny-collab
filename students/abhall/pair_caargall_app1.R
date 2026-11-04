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
      plotlyOutput("graph"),
      tableOutput("table"),
    )
  )
)


server <- function(input, output) {

    newmtcars <- mtcars |>
      rownames_to_column(var = "name")
  
    # use plot_ly function to create 3D scatter plot
    output$graph <- renderPlotly({
      plot_ly(
            data = filter(newmtcars, mpg >= input$mpg),
            x = ~mpg,
            y = ~get(input$yVariable),
            text = ~name,
            hoverinfo = "text"
            ) 
})

    output$table <- renderTable({
      filter(newmtcars, mpg >= input$mpg) |>
        select(name, mpg, qsec, wt)
    })

}
# Run the application 
shinyApp(ui = ui, server = server)

  