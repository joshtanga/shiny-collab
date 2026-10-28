# level 3 complexity - dynamic function parser
#
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  withMathJax(),
  tags$script(HTML(
    "
    $(document).on('shiny:visualchange shiny:value', function(event) {
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
  titlePanel('Graph of a custom function'),
  sidebarLayout(
    sidebarPanel(
      textInput(
        "func_str",
        "Enter function of x (e.g., x^2, sin(x), log(x + 1)):",
        value = "x^2"
      ),
      sliderInput(
        "x",
        "Current x-coordinate",
        min = -10,
        max = 10,
        value = 2,
        step = 0.1
      )
    ),
    mainPanel(
      plotOutput("graph"),
      tableOutput("table")
    )
  )
)

server <- function(input, output) {
  # 1. Parse and evaluate the function expression across the grid once
  eval_data <- reactive({
    req(input$func_str)
    x_val <- seq(-10, 10, length.out = 200)

    y_val <- tryCatch(
      {
        with(list(x = x_val), eval(parse(text = input$func_str)))
      },
      error = function(e) {
        rep(NA_real_, length(x_val))
      }
    )

    tibble(x_val = x_val, y_val = y_val)
  })

  # 2. Get the specific y value at input$x using approx() on eval_data()
  current_y <- reactive({
    df <- eval_data()
    # Interpolate y at the slider's x position
    approx(df$x_val, df$y_val, xout = input$x)$y
  })

  output$graph <- renderPlot({
    df <- eval_data()
    cy <- current_y()

    ggplot(df, aes(x = x_val, y = y_val)) +
      geom_line(color = "steelblue", size = 1.2) +
      geom_point(aes(x = input$x, y = cy), size = 12, color = "darkorange") +
      geom_point(aes(x = input$x, y = cy), size = 6, color = "white") +
      labs(x = "x", y = "y", title = paste0("y = ", input$func_str)) +
      theme_minimal()
  })

  output$table <- renderTable(
    {
      cy <- current_y()
      tibble(
        "\\(x\\)" = input$x,
        "\\(y\\)" = cy
      )
    },
    sanitize.text.function = identity
  )
}
shinyApp(ui = ui, server = server)
