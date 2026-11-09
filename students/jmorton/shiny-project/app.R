# Shiny app
installed.packages("plotly")
installed.packages("datasets")
installed.packages("bslib")
installed.packages("shiny")
installed.packages("shinyWidgets")
installed.packages("tidyverse")
library(plotly)
library(datasets)
library(bslib)
library(shiny)
library(shinyWidgets)
library(tidyverse)

#
ui <- page_fillable(
  titlePanel("Time-dependent Theoph Concentration"),

  # Top row: two shorter cards
  layout_columns(
    col_widths = c(6, 6),

    card(
  height = "150px",
  sliderTextInput(
    inputId = "Subject",
    label = "Choose Subject",
    choices = as.character(unique(Theoph$Subject)),
    selected = "1")),

    card(
      height = "150px",
      card_body(
        p("Theoph")
      )
    )
  ),

  # Bottom row: full-width, taller graph
  card(
    height = "576px",
    width = "100%",
    card_body(
      plotlyOutput(
        "graph",
        width = "100%",
        height = "500px")))
      )
  
# 
server <- function(input, output) {
  output$graph <- renderPlotly({   
    fig <- plot_ly(
      filter(Theoph,
      Subject == input$Subject), 
       x = ~Time,
       y = ~conc,
       color = ~Subject)
    fig <- fig |> add_markers()
    fig <- fig |> add_lines()
    fig <- fig |> layout(title = 'Time-dependent Theoph Concentration', 
    xaxis = list(title = 'Time (hr)'),
    yaxis = list(title = 'Concentration'))
  })} 

# 
shinyApp(ui = ui, server = server)
