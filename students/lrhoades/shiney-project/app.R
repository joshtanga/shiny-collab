library(shiny)
library(bslib)
library(tidyverse)
library(janitor)

VideoG <- read_csv("data/VideoGameData.csv") |>
  clean_names()

glimpse(VideoG)

data <- VideoG |>
  select(name, platform, year_of_release, genre, publisher, na_sales, eu_sales, global_sales)

missing_values <- data |>
  summarise(across(everything(), ~sum(is.na(.x)))) |>
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "missing_count"
  )

missing_values

data <- data |>
  filter(str_detect(as.character(year_of_release), "^[0-9]{4}$")) |>
  mutate(year_of_release = as.integer(year_of_release)) |>
  drop_na(name, platform, year_of_release, genre, publisher, na_sales, eu_sales, global_sales)

ui <- page_sidebar(
  title = "Video Game Publisher Sales",

  sidebar = sidebar(
    h4("filters"),

    selectInput(
      "publisher",
      "Select Publisher:",
      choices = c("All Publishers", sort(unique(data$publisher))),
      selected = "All Publishers"
    ),

    selectInput(
      "genre",
      "Select Genre",
      choices = c("All Genres", sort(unique(data$genre))),
      selected = "All Genres"
    ),

    sliderInput(
      "year",
      "Select Year Range:",
      min = min(data$year_of_release),
      max = max(data$year_of_release),
      value = range(data$year_of_release),
      step = 1,
      sep = ""
    )
  ),
  
  h3("Top Video Game Publishers By Global Sales"),

  plotOutput("publisher_plot")
)

server <- function(input, output){

  filtered_games <- reactive({

    filtered_data <- data

    if(input$publisher != "All Publishers") {
      filtered_data <- filtered_data |>
        filter(publisher == input$publisher)
    }

    if(input$genre != "All Genres") {
      filtered_data <- filtered_data |>
        filter(genre == input$genre)
    }

    filtered_data <- filtered_data |>
      filter(
        year_of_release >= input$year[1],
        year_of_release <= input$year[2]
      )
    
    filtered_data
  })

  output$publisher_plot <- renderPlot({

    filtered_games() |>
      group_by(publisher) |>
      summarise(total_sales = sum(global_sales), .groups = "drop") |>
      slice_max(total_sales, n = 10, with_ties = FALSE) |>
      ggplot(aes(x = reorder(publisher, total_sales), y = total_sales)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(
        title = "Global Sales by Publisher",
        x = "Publisher",
        y = "Global Sales (Millions of Copies)"
      ) +
      scale_y_continuous(labels = scales::label_number(suffix = "M"))+
      theme_minimal()
  })
}

shinyApp(ui, server)