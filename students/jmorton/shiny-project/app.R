# Shiny app
installed.packages("plotly")
installed.packages("bslib")
installed.packages("shiny")
installed.packages("shinyWidgets")
installed.packages("tidyverse")
installed.packages("janitor")
installed.packages("scales")
library(plotly)
library(bslib)
library(shiny)
library(shinyWidgets)
library(tidyverse)
library(janitor)
library(scales)


Stroke <- readr::read_csv(
  "C:/Users/jmorton/shiny-collab/students/jmorton/data/healthcare-dataset-stroke-data.csv") |>
  janitor::clean_names()

glimpse(Stroke)

missing <- Stroke |>
  summarize(across(everything(),
      ~ sum(is.na(.x)))) |>
  pivot_longer(
    cols = everything(),
    names_to = "Variable",
    values_to = "N/A_count") 

missing

Stroke_clean <- Stroke |>
  tidyr::drop_na()

view(Stroke_clean)

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
