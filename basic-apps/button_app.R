# this shiny app displays a plot of the 2024 US presidential election results by county
# it's purpose is to show how to use buttons to switch between two different plots in a single output area

library(shiny)
library(bslib)
library(tidyverse)


# create data and two plots:
# data: edf
# plot1: counties colored by winner
# plot2: counties colored by winner, weighted by population

# expecting the app to be run from the shiny-collab/starter-code directory,
# so the data load file is up one directory in the starter-code subdirectory
source('../starter-code/election_data_2024_load.R')

ui <- page_fluid(
  radioButtons(
    "cp",
    "Counties vs. Popular Vote",
    c("Counties", "Popular Vote"),
    inline = TRUE
  ),
  plotOutput("plot1")
)

server <- function(input, output, session) {
  output$plot1 <- renderPlot({
    if (input$cp == 'Counties') {
      plot1
    } else {
      plot2
    }
  })
}

shinyApp(ui, server)
