# Based on the class map: data, UI, then server.
library(shiny)
library(bslib)
library(tidyverse)
library(scales)
library(sf)
library(usmap)

# Find the CSV from any folder inside the repo.
find_county_data <- function() {
  folder <- normalizePath(getwd(), winslash = "/")
  repeat {
    path <- file.path(folder, "data", "2024_US_County_Level_Presidential_Results.csv")
    if (file.exists(path)) return(path)
    parent <- dirname(folder)
    if (parent == folder) break
    folder <- parent
  }
  stop("Open the shiny-collab project before running this app.")
}

# ---- data ----
votes <- read_csv(find_county_data(), col_types = cols(
  county_fips = col_character(), fips = col_character(), .default = col_guess()
)) |>
  transmute(fips = str_pad(county_fips, 5, pad = "0"),
    population = pop, density = pop_dens,
    winner = case_when(votes_dem > votes_gop ~ "Harris",
                       votes_gop > votes_dem ~ "Trump",
                       votes_dem == votes_gop ~ "Tie", TRUE ~ NA_character_))

# Match counties by code; keep the class map's lower-48 layout.
stopifnot(!anyDuplicated(votes$fips))
county_map <- us_map("counties", exclude = c("AK", "HI")) |>
  filter(as.integer(substr(fips, 1, 2)) <= 56) |>
  select(fips, geom) |>
  left_join(votes, by = "fips") |>
  mutate(usable = is.finite(population) & population >= 0 &
           is.finite(density) & density >= 0 & !is.na(winner))
stopifnot(any(county_map$usable))
population_limit <- ceiling(max(county_map$population[county_map$usable]))
density_limit <- ceiling(max(county_map$density[county_map$usable]))
map_colors <- c(Harris = "#00AEF3", Trump = "#E81B23", Tie = "#8064A2",
                `Outside range` = "#B0B0B0", `Missing data` = "#F3F1E8")

# Keep every shape; change only its color.
classify_counties <- function(pop_bounds, density_bounds) {
  county_map |>
    mutate(status = case_when(
      !usable ~ "Missing data",
      population < pop_bounds[1] | population > pop_bounds[2] |
        density < density_bounds[1] | density > density_bounds[2] ~ "Outside range",
      TRUE ~ winner))
}
draw_map <- function(data) {
  ggplot(data) +
    geom_sf(aes(fill = status), color = "white", linewidth = 0.06) +
    scale_fill_manual(values = map_colors, limits = names(map_colors), drop = FALSE) +
    labs(fill = NULL) + theme_void() +
    theme(legend.position = "bottom", legend.text = element_text(size = 11),
          plot.background = element_rect(fill = "white", color = NA))
}

# Reuse the controls for both filters.
range_controls <- function(id, title, upper, step) {
  card(card_header(title),
    sliderInput(paste0(id, "_range"), "Selected range", min = 0, max = upper,
                value = c(0, upper), step = step, sep = ",", width = "100%"),
    fluidRow(
      column(6, numericInput(paste0(id, "_min"), "Minimum", 0,
                            min = 0, max = upper, step = step)),
      column(6, numericInput(paste0(id, "_max"), "Maximum", upper,
                            min = 0, max = upper, step = step))),
    textOutput(paste0(id, "_error")))
}

# ---- UI ----
ui <- page_fluid(
  titlePanel("Population, density, and the 2024 election"),
  p("A county keeps its election color only when it fits BOTH selected ranges."),
  fluidRow(
    column(6, range_controls("population", "Population (people)", population_limit, 1)),
    column(6, range_controls("density", "Population density (people per square mile)", density_limit, 0.1))),
  actionButton("reset", "Reset both filters"),
  card(card_header("2024 county winners: contiguous United States"),
    textOutput("summary"), plotOutput("map", height = "650px"),
    p("Gray counties are outside your ranges. Cream counties have missing data. Alaska and Hawaii are excluded, matching the class map.")),
  p("Population counts residents, not voters. County shapes show land area, not population. Population reference year has not yet been confirmed.")
)

# ---- server ----
server <- function(input, output, session) {
  # Link each slider with its two number boxes.
  bind_range <- function(id, upper) {
    bounds <- reactiveVal(c(0, upper))
    valid <- function(x) {
      length(x) == 2 && all(is.finite(x)) &&
        x[1] >= 0 && x[2] <= upper && x[1] <= x[2]
    }
    observeEvent(input[[paste0(id, "_range")]], {
      x <- input[[paste0(id, "_range")]]
      req(valid(x))
      bounds(x)
      updateNumericInput(session, paste0(id, "_min"), value = x[1])
      updateNumericInput(session, paste0(id, "_max"), value = x[2])
    }, priority = 10)
    observeEvent(list(input[[paste0(id, "_min")]], input[[paste0(id, "_max")]]), {
      x <- c(input[[paste0(id, "_min")]], input[[paste0(id, "_max")]])
      req(valid(x))
      if (!isTRUE(all.equal(x, bounds()))) {
        bounds(x)
        updateSliderInput(session, paste0(id, "_range"), value = x)
      }
    })
    output[[paste0(id, "_error")]] <- renderText({
      x <- c(input[[paste0(id, "_min")]], input[[paste0(id, "_max")]])
      if (valid(x)) return("")
      paste("Enter a minimum no greater than the maximum, between 0 and",
            comma(upper), ". The last valid range stays active.")
    })
    observeEvent(input$reset, {
      bounds(c(0, upper))
      updateSliderInput(session, paste0(id, "_range"), value = c(0, upper))
      updateNumericInput(session, paste0(id, "_min"), value = 0)
      updateNumericInput(session, paste0(id, "_max"), value = upper)
    })
    bounds
  }
  population_bounds <- bind_range("population", population_limit)
  density_bounds <- bind_range("density", density_limit)

  # Both filters include their minimum and maximum.
  mapped <- reactive(classify_counties(population_bounds(), density_bounds()))
  output$map <- renderPlot(draw_map(mapped()))
  output$summary <- renderText({
    data <- mapped()
    paste0(comma(sum(data$status %in% c("Harris", "Trump", "Tie"))),
           " counties in range | ", comma(sum(data$status == "Outside range")),
           " outside range | ", comma(sum(data$status == "Missing data")), " missing data")
  })
}
shinyApp(ui, server)
