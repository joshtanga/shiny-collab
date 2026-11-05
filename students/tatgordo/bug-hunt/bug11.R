# ------------------------------------------------------------
# BUG HUNT 11   difficulty: ***
# Symptom:  no errors, but the card title and the plot
#           disagree. The title says one pair of variables;
#           the plot shows a different pair.
# Goal:     each click picks ONE random pair, and the title
#           and plot both describe that same pair.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)

num_vars <- names(mtcars)

ui <- page_sidebar(
  title = "Random pair of variables",
  sidebar = sidebar(
    actionButton("go", "Pick a random pair")
  ),
  card(
    card_header(textOutput("pair_title")),
    plotOutput("pair_plot")
  )
)

server <- function(input, output) {
  output$pair_title <- renderText({
    input$go # re-run on each click
    pair <- sample(num_vars, 2)
    str_c(pair[1], " vs ", pair[2])
  })

  output$pair_plot <- renderPlot({
    input$go # re-run on each click
    pair <- sample(num_vars, 2)
    ggplot(mtcars, aes(x = .data[[pair[1]]], y = .data[[pair[2]]])) +
      geom_point(size = 3) +
      theme_minimal()
  })
}

shinyApp(ui, server)
