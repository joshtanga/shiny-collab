# ------------------------------------------------------------
# App:        jduerst_app2.R
# Author:     Janson Duerst
# Started from: starter-apps/app-basic3.R
# What I changed:
#
# ------------------------------------------------------------

library(shiny)
library(tidyverse)
library(bslib)

# notice syntax for fluid page using bslib
# page_fluid(titlePanel(...), sidebarLayout(...))
# sidebarLayout(sidebarPanel(...), mainPanel(...))
ui <- page_fluid(
  # raw string for LaTeX
  # format for pretty printing of math in R Markdown
  withMathJax(),
  # Script to trigger MathJax typesetting after dynamic updates
  tags$script(HTML(
    "
    $(document).on('shiny:visualchange', function(event) {
      if (window.MathJax) {
        if (window.MathJax.Hub && typeof window.MathJax.Hub.Queue === 'function') {
          window.MathJax.Hub.Queue(['Typeset', window.MathJax.Hub]);
        } else if (window.MathJax.typesetPromise) {
          window.MathJax.typesetPromise();
        }
      }
    });
  "
  )),
  titlePanel('Graph of a function \\(y = e^{sin(x)}cos(x)x\\)'),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "x",
        "Current x-coordinate",
        min = -100,
        max = 100,
        value = 30
      )
    ),
    mainPanel(plotOutput("graph"), tableOutput("table"))
  )
)


server <- function(input, output) {
  X <- c(-100:100)
  # reactive section ------------------------
  output$graph <- renderPlot({
    y <- exp(sin(input$x))*cos(input$x)*input$x
    df <- tibble(x_val = X, y_val = exp(sin(X))*cos(X)*X)

    ggplot(df, aes(x = x_val, y = y_val)) +
      geom_line() +
      geom_point(aes(x = input$x, y = y), size = 20) +
      # adding a white point on top to make it more visible
      geom_point(aes(x = input$x, y = y), size = 10, color = "white")
  })

  output$table <- renderTable(
    {
      tibble(
        "\\(x\\)" = input$x,
        "\\(e^{sin(x)}cos(x)x\\)" = exp(sin(input$x))*cos(input$x)*input$x
      )
    },
    sanitize.text.function = identity
  )
}

# Run the application
shinyApp(ui = ui, server = server)
