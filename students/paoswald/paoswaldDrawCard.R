# ------------------------------------------------------------
# App:        racbrown_app1.R
# Author:     Rachel Brown
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - swapped the y = x^2 curve for the gapminder dataset
#   - added a selectInput for continent
# ------------------------------------------------------------
# Patton Oswald's Changes:
#    - Added a "dark mode" button

library(shiny)
library(bslib)
library(tidyverse)
library(gapminder)

ui <- page_fluid(
  page_sidebar(
    theme = bs_theme(bootswatch = "flatly"),
    sidebar = sidebar(input_dark_mode()),
  ),
  titlePanel("Life Expectancy vs. GDP per Capita"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("year",
                  "Year",
                  min = 1952,
                  max = 2007,
                  value = 2007,
                  step = 5,
                  sep = ""),
      selectInput("continent",
                  "Continent",
                  choices = levels(gapminder$continent),
                  selected = "Europe")
    ),
    mainPanel(
      plotOutput("myplot")
    )
  )
)

server <- function(input, output) {
  output$myplot <- renderPlot({
    d <- gapminder |>
      filter(year == input$year, continent == input$continent)

    ggplot(d, aes(x = gdpPercap, y = lifeExp, size = pop)) +
      geom_point(alpha = 0.6) +
      scale_x_log10() +
      labs(x = "GDP per capita (USD, log scale)",
           y = "Life expectancy (years)",
           size = "Population")
  })
}

shinyApp(ui = ui, server = server)