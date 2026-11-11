library(tidyverse)
library(jsonlite)
library(shiny)
library(bslib)

data <- read.csv("data/nhtsa-complaints-by-model-2010-2025.csv")
stats <- fromJSON("data/most-complained-2026-q3.json")

top_cars <- stats$rows

ui <- page_fillable(
  layout_sidebar(
    sidebar = sidebar(
      h1("Most Complained Car Models Via NHTSA"),
      p("Click the button to get a random car year and model from the top 100 most complained about cars via NHTSA."),
      selectInput("make_choice", "Filter by Make", choices = c("All", unique(top_cars$make))),
      actionButton("click_me", "Click Me"),
      sliderInput("num_bars", "Number of Components", min = 3, max = 15, value = 10)
    ),  
    value_box(
      title = "Selected Vehicle",
      value = textOutput("car_box")
    ),
    card(
      card_header("Top 100 Most Complained Components"),
      plotOutput("my_plot")
    ),
     card(
      card_header("Component Counts"),
      tableOutput("my_table")
    )
  )
)

server <- function(input, output, session){
 random_car <- eventReactive(
    list(input$click_me, input$make_choice),
    {
      if (input$make_choice == "All") {
        top_cars |> slice_sample(n = 1)
      } else {
        top_cars |> filter(make == input$make_choice) |> slice_sample(n = 1)
      }
    },
    ignoreNULL = FALSE
  )
   matches <- reactive({
    car <- random_car()
    data |>
      filter(
        make == car$make,
        model == car$model,
        model_year == car$model_year
      ) |>
      slice_max(complaints, n = input$num_bars)
  })

output$car_box <- renderText({
    car <- random_car()
    paste0(car$vehicle, " (Rank ", car$rank, ")")
  })

  output$my_plot <- renderPlot({
    car <- random_car()
    matches <- data |> filter( make== car$make,
    model == car$model,
    model_year == car$model_year) |> slice_max(complaints, n=10)

    ggplot(matches, aes(x = reorder(component, complaints), y = complaints)) +
      geom_col(fill = '#3BEEF5' ) +
      coord_flip() +
        labs( title = paste0("Complaints for ", car$vehicle),
        subtitle = paste0("Rank ", car$rank),
         x=NULL,
        y = "Number of complaints") + 
          theme_minimal()
  })
  output$my_table <- renderTable({
    matches() |> select(Component = component, Complaints = complaints)
  })
}

shinyApp(ui = ui, server = server)