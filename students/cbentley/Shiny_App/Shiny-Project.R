# App: Shiny_Project
# Author: Caity Bentley
# Kaggle Data: Modern Lifestyle & Sleep Health Metrics (Maria Aqdas 2026)
# *Dataset from Mini Project 2

library(tidyverse)
library(scales)
library(shiny)
library(bslib)
library(plotly)

# setwd("./students/cbentley/Shiny_App")
# getwd()

# Import kaggle data

sleep_raw <- readr::read_csv('modern_lifestyle_and_sleep_health_2026.csv')

# Data cleaning and prep

## Select only columns I need
sleep <- sleep_raw |> select(physical_activity_mins, sleep_duration_hours, 
  sleep_quality_score)

## Categorize data
sleep <- sleep |> 
  mutate(activity_level = factor(
      case_when(
        physical_activity_mins < 30 ~ "Low (<30 min)",
        physical_activity_mins < 60 ~ "Medium (30-59 min)",
        physical_activity_mins >= 60 ~ "High (60+ min)"),
      levels = c("Low (<30 min)", "Medium (30-59 min)", "High (60+ min)")
    )
  )

ui <- page_sidebar(
  title = "Comparing Physical Activity and Sleep Duration",
sidebar = sidebar(
  selectInput(
  inputId = "activity",
  label = "Choose an Activity Level",
  choices = c("Low" = "Low (<30 min)", "Medium" = "Medium (30-59 min)", 
  "High" = "High (60+ min)" )),
sliderInput(
  "sleep_duration_hours",
  "Set sleep duration",
  min = 3.60,
  max = 9.70,
  value = c(3.60, 9.70),
  step = 0.1),
plotlyOutput("graph"),
 navset_card_tab(
    id = "tabs",
    nav_panel("Low",    value = "Low (<30 min)",       tableOutput("table_low")),
    nav_panel("Medium", value = "Medium (30-59 min)",  tableOutput("table_medium")),
    nav_panel("High",   value = "High (60+ min)",      tableOutput("table_high"))
      )
    )
  )




server <- function(input, output, session) {
observeEvent(input$activity, {
    nav_select("tabs", selected = input$activity)
  })

  # tabs -> dropdown
  observeEvent(input$tabs, {
    updateSelectInput(session, "activity", selected = input$tabs)
  })

filtered <- reactive({
 sleep |>
      filter(activity_level == input$activity,
      between(sleep_duration_hours,
              input$sleep_duration_hours[1],
              input$sleep_duration_hours[2]))
})

  output$graph <- renderPlotly({
    plot_ly(filtered(),
            x = ~physical_activity_mins,
            y = ~sleep_duration_hours,
            color = ~activity_level,
            type = "scatter",
            mode = "markers") |>
      layout(
        xaxis = list(title = "Physical Activity Minutes"),
        yaxis = list(title = "Sleep Duration")
      )
  })


  output$table_low <- renderTable({
    filtered() |> filter(activity_level == "Low (<30 min)") |> head(50)
  })
    

   output$table_medium <- renderTable({
    filtered() |> filter(activity_level == "Medium (30-59 min)") |> head(50)
   })

    output$table_high <- renderTable({
    filtered() |> filter(activity_level == "High (60+ min)") |> head(50)
  })
  
}

shinyApp(ui = ui, server = server)