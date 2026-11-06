# ------------------------------------------------------------
# BUG HUNT 03   difficulty: *
# Symptom:  no errors, but the second card is missing its
#           title bar. The first card has one; the second
#           doesn't.
# ------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)

ui <- page_fillable(
  layout_columns(
    card(
      card_header("Miles per gallon"),
      plotOutput("mpg_plot")
    ),
    card(
      card_header = "Summary",
      tableOutput("mpg_table")
    )
  )
)

server <- function(input, output) {
  output$mpg_plot <- renderPlot({
    ggplot(mtcars, aes(x = factor(cyl), y = mpg)) +
      geom_boxplot() +
      labs(x = "Cylinders", y = "MPG") +
      theme_minimal()
  })

  output$mpg_table <- renderTable({
    mtcars |>
      group_by(cyl) |>
      summarize(n = n(), mean_mpg = mean(mpg))
  })
}

shinyApp(ui, server)
