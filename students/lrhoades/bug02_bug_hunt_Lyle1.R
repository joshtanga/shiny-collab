# ------------------------------------------------------------
# BUG HUNT 02   difficulty: *
# Symptom:  the app runs and there are no errors, but the
#           plot never shows up. The main area is empty.
# I changed so much trying to mkae this work and then i relised that all that was wrong was plotOutput
# had the wrong variable name it was mass_plot and the variable name was massplot so i changed
# a lot but that was the bug.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(palmerpenguins)

ui <- page_fluid(
  title = "Penguin body mass",
  sidebarLayout(
    checkboxGroupInput("species", "Species",
      choices = c("Adelie", "Chinstrap", "Gentoo"),
      selected = c("Adelie", "Chinstrap", "Gentoo")
    ),
    mainPanel(
    plotOutput("massplot")
    )
  )
)

server <- function(input, output) {
  output$massplot <- renderPlot({
    penguins |>
      filter(species %in% input$species) |>
      ggplot(aes(x = species, y = body_mass_g, fill = species)) +
      geom_boxplot() +
      theme_minimal()
  })
}

shinyApp(ui = ui,server = server)
