library(shiny)
library(bslib)
library(bsicons)
library(tidyverse)
library(scales)
library(janitor)

#Data import and cleaning
df <- read_csv("data/vgsales.csv", na = c("", "NA", "N/A")) |>
  clean_names() |>
  drop_na() |>
  mutate(year = as.integer(year))

genres <- c("Shooter", "Puzzle", "Platform")
genre_colors <- c(Shooter = "RED", Puzzle = "GREEN", Platform = "BLUE")

ui <- page_fillable(
  theme = bs_theme(version = 5),
  titlePanel("Video Game Sales Explorer"),

  tabsetPanel(
    tabPanel("Table",
      h4("Top 10 best-selling games"),
      tableOutput("top_games")
    ),

    tabPanel("Graph",
      h4("Global sales by platform"),
      sliderInput(
        "min_sales",
        "Minimum global sales per game (millions)",
        min = 0,
        max = max(df$global_sales),
        value = 0,
        step = 0.1
      ),
      plotOutput("platform_plot")
    ),

    tabPanel("value_box",
      h4("Regional sales of Shooter, Puzzle, and Platform games"),
      selectInput(
        "year",
        "Select a year",
        choices = c("All years", sort(unique(df$year))),
        selected = "All years"
      ),
      checkboxGroupInput(
        "genres",
        "Genres",
        choices = genres,
        selected = genres,
        inline = TRUE
      ),

      layout_columns(
        col_widths = breakpoints(sm = c(3, 3, 3, 3)),
        value_box(
          title = "North America",
          value = uiOutput("na_box"),
          showcase = bs_icon("globe-americas"),
          theme = "primary"
        ),
        value_box(
          title = "Europe",
          value = uiOutput("eu_box"),
          showcase = bs_icon("globe-europe-africa"),
          theme = "primary"
        ),
        value_box(
          title = "Japan",
          value = uiOutput("jp_box"),
          showcase = bs_icon("globe-asia-australia"),
          theme = "primary"
        ),
        value_box(
          title = "Other",
          value = uiOutput("other_box"),
          showcase = bs_icon("globe"),
          theme = "primary"
        )
      ),

      plotOutput("region_genre_plot", height = "550px")
    )
  )
)

server <- function(input, output, session) {

  output$top_games <- renderTable({
    df |>
      arrange(desc(global_sales)) |>
      select(Name = name, Platform = platform, Year = year,
             Genre = genre, Global_Sales = global_sales) |>
      head(10)
  })

  output$platform_plot <- renderPlot({
    df |>
      filter(global_sales >= input$min_sales) |>
      group_by(platform) |>
      summarise(global_sales = sum(global_sales), .groups = "drop") |>
      ggplot(aes(x = reorder(platform, global_sales), y = global_sales)) +
      geom_bar(stat = "identity", fill = "black") +
      coord_flip() +
      scale_y_continuous(labels = label_comma()) +
      labs(
        title = "Total global sales by platform",
        x = "Platform",
        y = "Total global sales (millions)"
      ) +
      theme_minimal(base_size = 14)
  })

  # Shared reactive #1: games in the selected genres
  genre_data <- reactive({
    req(input$genres)
    df |> filter(genre %in% input$genres)
  })

  # Shared reactive #2: selected genres, filtered by the selected year
  year_data <- reactive({
    d <- genre_data()
    if (input$year != "All years") {
      d <- d |> filter(year == as.integer(input$year))
    }
    d
  })

  fmt <- function(x) {
    paste0(format(round(x, 1), nsmall = 1, big.mark = ","), "M")
  }

  # Builds the content of one region box: one line per selected genre
  region_box <- function(col) {
    d <- year_data()
    div(
      style = "font-size: 1.1rem; font-weight: normal;",
      lapply(input$genres, function(g) {
        p(style = "margin: 0;",
          paste0(g, ": ", fmt(sum(d[[col]][d$genre == g]))))
      })
    )
  }

  output$na_box    <- renderUI(region_box("na_sales"))
  output$eu_box    <- renderUI(region_box("eu_sales"))
  output$jp_box    <- renderUI(region_box("jp_sales"))
  output$other_box <- renderUI(region_box("other_sales"))

  # One panel per region, one line per genre, across all years
  output$region_genre_plot <- renderPlot({
    genre_data() |>
      pivot_longer(
        cols = c(na_sales, eu_sales, jp_sales, other_sales),
        names_to = "region",
        values_to = "sales"
      ) |>
      mutate(region = factor(
        region,
        levels = c("na_sales", "eu_sales", "jp_sales", "other_sales"),
        labels = c("North America", "Europe", "Japan", "Other")
      )) |>
      group_by(year, region, genre) |>
      summarise(sales = sum(sales), .groups = "drop") |>
      ggplot(aes(x = year, y = sales, color = genre)) +
      geom_line(linewidth = 1) +
      facet_wrap(~region, ncol = 2, scales = "free_y") +
      scale_color_manual(values = genre_colors) +
      scale_y_continuous(labels = label_comma()) +
      labs(
        title = "Yearly sales by region and genre",
        x = "Year",
        y = "Sales (millions)",
        color = "Genre"
      ) +
      theme_minimal(base_size = 14)
  })
}

shinyApp(ui = ui, server = server)