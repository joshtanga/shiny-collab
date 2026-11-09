# App: Shiny_Project
# Author: Caity Bentley
# Kaggle Data: Modern Lifestyle & Sleep Health Metrics (Maria Aqdas 2026)
# *Dataset from Mini Project 2

library(tidyverse)
library(scales)
library(shiny)
library(bslib)


# Import kaggle data

sleep_raw <- readr::read_csv('modern_lifestyle_and_sleep_health_2026.csv')

# Data cleaning and prep

## Select only columns I need
sleep <- sleep_raw |> select(physical_activity_mins, sleep_duration_hours, 
  sleep_quality_score)

ui <- page_sidebar(
  titlePanel("Comparing Physical Activity and Sleep Duration"),
sidebar = sidebar(
  selectInput(
  inputId = "activity_level",
  label = "Choose an Activity Level",
  choices = c("Low" = "low (<30 min)", "Medium" = "Medium (30-59 min)", 
  "High" = "High (60+ min)" )),
sliderInput(
  "sleep_duration_hours",
  "Set sleep duration",
  min = 3.60,
  max = 9.70,
  value = c(3.60, 9.70)
),
mainPanel(plotlyOutput("graph"))
))


server <- function(input, output) {
filtered <- reactive({sleep |> 
  mutate(activity_level = factor(
      case_when(
        physical_activity_mins < 30 ~ "Low (<30 min)",
        physical_activity_mins < 60 ~ "Medium (30-59 min)",
        physical_activity_mins >= 60 ~ "High (60+ min)"),
      levels = c("Low (<30 min)", "Medium (30-59 min)", "High (60+ min)")
    )
  )
})

  output$graph <- renderPlotly({
    plot_ly(filtered(),
            x = ~physical_activity_mins,
            y = ~sleep_duration_hours,
            z = ~sleep_quality_score,
            color = ~activity_level,
            type = "scatter3d",
            mode = "markers") |>
      layout(scene = list(
        xaxis = list(title = "Physical Activity Minutes"),
        yaxis = list(title = "Sleep Duration"),
        zaxis = list(title = "Sleep Quality")
      ))
  })
}

shinyApp(ui = ui, server = server)