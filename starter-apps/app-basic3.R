# level 3 complexity
#
# new additions:
# we format latex in the title & table using withMathJax() and \\( ... \\) syntax

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
  titlePanel('Graph of a function \\(y = x^2\\)'),
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
    y <- input$x^2
    df <- tibble(x_val = X, y_val = X^2)

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
        "\\(x^2\\)" = (input$x)^2
      )
    },
    sanitize.text.function = identity
  )
}

# Run the application
shinyApp(ui = ui, server = server)
