# ------------------------------------------------------------
# App:        jduerst_app2.R
# Author:     Janson Duerst
# Started from: starter-apps/app-basic3.R
# What I changed:
# Changed the function
# Added color to the graph
# Changed it so the graph graphs every .1 of x, instead of 1 of x
# Changed size of point, so it was easier to see the complex graph
# Changed bounds of graph, and starting value
# Changed shape of point
# ------------------------------------------------------------

library(shiny)
library(tidyverse)
library(bslib)
library(scales)

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
        min = -150,
        max = 150,
        value = 5
      )
    ),
    mainPanel(plotOutput("graph"), tableOutput("table"))
  )
)


server <- function(input, output) {
  X <- seq(-150,150,.1)
  # reactive section ------------------------
  output$graph <- renderPlot({
    y <- exp(sin(input$x))*cos(input$x)*input$x
    df <- tibble(x_val = X, y_val = exp(sin(X))*cos(X)*X)

    ggplot(df, aes(x = x_val, y = y_val, color=y_val)) +
      geom_line() +
      geom_point(aes(x = input$x, y = y), size = 5, shape = 18, color = "black") +
      # adding a white point on top to make it more visible
      scale_color_viridis_c()+
      theme(legend.position = "none")+
      geom_point(aes(x = input$x, y = y), size = 2, color = "white", shape = 18)
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
