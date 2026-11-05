library(plotly)
library(palmerpenguins)

# What I learned is that I cant use download button because there is no csv in this doc

# level 4 complexity
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Filtering bill depth with slider with plotly"),
  sidebarLayout(
    sidebarPanel(
        # Range slider: value = c(low, high) keeps rows between the two handles
        sliderInput("bill_depth",
                  "Set bill depth range",
                  min = 13.1,
                  max = 21.5,
                  value = c(14, 18)),
        selectInput("sex",
                  "Choose sex",
                  choices = c("male","female"),
                  selected = "female"),
      selectInput("species",
            "Choose species",
            choices = c("Adelie", "Chinstrap", "Gentoo"),
            selected = "Adelie")
          ),
    mainPanel(
      plotlyOutput("graph"),
      tableOutput("table")
    )
  ),
  value_box(title = "Penguins shown", value = textOutput("n_shown")),
  plotOutput("plot", brush = "plot_brush"),
  tableOutput("selected")
)


server <- function(input, output) {

  # One filtered dataset shared by every output
  filtered <- reactive({
    filter(penguins,
           between(bill_depth_mm, input$bill_depth[1], input$bill_depth[2]),
           sex == input$sex,
           species == input$species)
  })

  output$graph <- renderPlotly({
    df <- filtered()
    validate(
      need(nrow(df) > 0, "No rows match. Try widening your filters.")
    )
    plot_ly(df,
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species,
            type = "scatter3d",
            mode = "markers") |>
      layout(scene = list(xaxis = list(title = "Body Mass"),
                          yaxis = list(title = "Bill Length"),
                          zaxis = list(title = "Flipper Length")))
  })

  output$table <- renderTable({
    filtered() |>
      arrange(desc(body_mass_g)) |>
      transmute(body_mass = body_mass_g,
                bill_length = bill_length_mm,
                flipper_length = flipper_length_mm,
                species = species)
  })

  output$n_shown <- renderText(nrow(filtered()))

  # Brushable 2D plot that feeds the "selected" table
  output$plot <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No rows match. Try widening your filters."))
    ggplot(df, aes(body_mass_g, bill_length_mm, color = species)) +
      geom_point()
  })

  output$selected <- renderTable({
    brushedPoints(filtered(), input$plot_brush)
  })

}

# Run the application 
shinyApp(ui = ui, server = server)