# ------------------------------------------------------------
# BUG HUNT 09   difficulty: **
# Symptom:  no errors, the plot looks fine, but the value
#           box always says "NA g" instead of a number.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(palmerpenguins)

ui <- page_sidebar(
  title = "Penguins by island",
  sidebar = sidebar(
    selectInput("island", "Island", choices = c("Biscoe", "Dream", "Torgersen"))
  ),
  value_box(
    title = "Average body mass",
    value = textOutput("avg_mass")
  ),
  plotOutput("mass_plot")
)

server <- function(input, output) {
  island_data <- reactive({
    penguins |> filter(island == input$island)
  })

  output$avg_mass <- renderText({
    str_c(round(mean(island_data()$body_mass_g, na.rm = TRUE)), " g") # FIX: added na.rm = TRUE inside the mean function
  })

  output$mass_plot <- renderPlot({
    ggplot(island_data(), aes(x = body_mass_g, fill = species)) +
      geom_histogram(bins = 20) +
      theme_minimal()
  })
}

shinyApp(ui, server)
