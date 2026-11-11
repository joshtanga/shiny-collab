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
  drop_na(name, platform, year_of_release, genre, publisher, na_sales, eu_sales, global_sales) |>
  mutate(year_of_release = as.integer(year_of_release))
ui <- page_sidebar(
  title = "Video Game Publisher Sales",

  sidebar = sidebar(
    h4("filters"),

    selectInput(
      "publisher",
      "Select Publisher:",
      choices = c("All Publishers", sort(unique(data$publisher))),
      selected = "All Publishers"
    )
  ),
  
  h3("Top Video Game Publishers By Global Sales"),

  plotOutput("publisher_plot")
)

server <- function(input, output){

  filtered_games <- reactive({
    if(input$publisher == "All Publishers") {
      data
    } else {
      data |>
        filter(publisher == input$publisher)
    }
  })

  output$publisher_plot <- renderPlot({

    filtered_games() |>
      group_by(publisher) |>
      summarise(total_sales = sum(global_sales), .group = "drop") |>
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