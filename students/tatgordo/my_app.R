# Population and voting in the 2024 presidential election
# Adapted from the professor's county-results app: data, UI, then server.
library(shiny)
library(bslib)
library(tidyverse)
library(scales)

# ---- data ------------------------------------------------------------------
# Find data whether R starts in the repo root or a folder inside the repo.
find_county_data <- function() {
  folder <- normalizePath(getwd(), winslash = "/")
  repeat {
    candidate <- file.path(folder, "data", "2024_US_County_Level_Presidential_Results.csv")
    if (file.exists(candidate)) return(candidate)
    parent <- dirname(folder)
    if (parent == folder) break
    folder <- parent
  }
  stop("Open the shiny-collab project, then run this app so it can find the data folder.")
}

votes <- read_csv(
  find_county_data(),
  col_types = cols(county_fips = col_character(), fips = col_character(),
                  .default = col_guess())
) |>
  transmute(
    county = str_c(county_name, ", ", state_name),
    population = pop,
    harris = votes_dem,
    trump = votes_gop,
    total = total_votes,
    harris_pct = 100 * harris / na_if(total, 0),
    trump_pct = 100 * trump / na_if(total, 0),
    winner = case_when(
      harris > trump ~ "Harris",
      trump > harris ~ "Trump",
      harris == trump ~ "Tie",
      TRUE ~ NA_character_
    )
  )

plot_votes <- votes |>
  filter(is.finite(population), population >= 0,
         is.finite(harris_pct), !is.na(winner)) |>
  mutate(
    # Fixed vertical spacing makes overlapping counties easier to click.
    # Only the horizontal position measures population.
    plot_row = match(winner, c("Trump", "Harris", "Tie")) +
      0.28 * sin(row_number() * 2.399963)
  )
stopifnot(nrow(plot_votes) > 0)
omitted_count <- nrow(votes) - nrow(plot_votes)
population_max <- max(100000, ceiling(max(plot_votes$population) / 1000) * 1000)
party_colors <- c(Harris = "#00AEF3", Trump = "#E81B23", Tie = "#777777")

# ---- ui --------------------------------------------------------------------
ui <- page_fluid(
  titlePanel("County population and the 2024 vote"),
  p("Each dot is a county. Farther right means more residents. Counties are grouped by who won the election."),
  card(
    card_header("Choose a population range"),
    sliderInput(
      "population_range", "County population (people): minimum and maximum",
      min = 0, max = population_max, value = c(0, 100000),
      step = 1, sep = ",", width = "100%"
    ),
    fluidRow(
      column(6, numericInput("population_min", "Minimum population", 0,
                             min = 0, max = population_max, step = 1)),
      column(6, numericInput("population_max", "Maximum population", 100000,
                             min = 0, max = population_max, step = 1))
    ),
    textOutput("range_error"),
    textOutput("range_summary")
  ),
  card(
    card_header("How big are the counties each candidate won?"),
    p("Blue = Harris won; red = Trump won; gray = tie. Dots are spread vertically only to reduce overlap. Click a dot for county details."),
    plotOutput("population_plot", click = "county_click", height = "500px")
  ),
  card(
    card_header("County details"),
    tableOutput("county_details")
  ),
  p(paste(comma(omitted_count),
          "rows excluded because population or election results are missing or invalid.")),
  p("Population is the number of residents, not the number of voters. Population reference year has not yet been confirmed.")
)

# ---- server ----------------------------------------------------------------
server <- function(input, output, session) {
  population_bounds <- reactiveVal(c(0, 100000))

  valid_bounds <- function(bounds) {
    length(bounds) == 2 && all(is.finite(bounds)) &&
      bounds[1] >= 0 && bounds[2] <= population_max && bounds[1] <= bounds[2]
  }

  observeEvent(input$population_range, {
    bounds <- input$population_range
    req(valid_bounds(bounds))
    population_bounds(bounds)
    updateNumericInput(session, "population_min", value = bounds[1])
    updateNumericInput(session, "population_max", value = bounds[2])
  }, priority = 10)

  observeEvent(list(input$population_min, input$population_max), {
    bounds <- c(input$population_min, input$population_max)
    req(valid_bounds(bounds))
    if (!isTRUE(all.equal(bounds, population_bounds()))) {
      population_bounds(bounds)
      updateSliderInput(session, "population_range", value = bounds)
    }
  })

  output$range_error <- renderText({
    bounds <- c(input$population_min, input$population_max)
    if (valid_bounds(bounds)) return("")
    paste("Enter a minimum no greater than the maximum, between 0 and",
          comma(population_max), ". Keeping the last valid range until then.")
  })

  filtered_votes <- reactive({
    bounds <- population_bounds()
    plot_votes |>
      filter(population >= bounds[1], population <= bounds[2])
  })

  output$range_summary <- renderText({
    paste(comma(nrow(filtered_votes())), "counties with populations from",
          comma(population_bounds()[1]), "to", comma(population_bounds()[2]),
          "people (including both endpoints).")
  })

  output$population_plot <- renderPlot({
    validate(need(nrow(filtered_votes()) > 0,
                  "No counties in this range. Move the slider handles farther apart."))
    ggplot(filtered_votes(), aes(x = population, y = plot_row, color = winner)) +
      geom_point(size = 2.5, alpha = 0.65) +
      scale_color_manual(values = party_colors, name = "County winner") +
      scale_x_continuous(labels = label_comma()) +
      scale_y_continuous(breaks = 1:3, labels = c("Trump", "Harris", "Tie"),
                         limits = c(0.5, if (any(filtered_votes()$winner == "Tie")) 3.5 else 2.5)) +
      labs(x = "County population (people)", y = "County winner") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom", panel.grid.minor = element_blank())
  })

  selected <- reactiveVal(NULL)
  observeEvent(population_bounds(), { selected(NULL) }, priority = 5)
  observeEvent(input$county_click, {
    hit <- nearPoints(filtered_votes(), input$county_click,
                      xvar = "population", yvar = "plot_row",
                      threshold = 10, maxpoints = 1)
    selected(if (nrow(hit) == 1) hit else NULL)
  })

  output$county_details <- renderTable({
    cur <- selected()
    validate(need(!is.null(cur), "Click a dot to see its county and results."))
    tibble(
      County = cur$county,
      Population = comma(cur$population),
      Winner = cur$winner,
      `Harris votes` = comma(cur$harris),
      `Trump votes` = comma(cur$trump),
      `Total votes` = comma(cur$total),
      `Harris share` = percent(cur$harris_pct / 100, accuracy = 0.1),
      `Trump share` = percent(cur$trump_pct / 100, accuracy = 0.1)
    )
  }, striped = TRUE, spacing = "s")
}

shinyApp(ui = ui, server = server)
