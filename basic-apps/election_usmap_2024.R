# US 2024 presidential results by county
# click a county to see its results
library(shiny)
library(bslib)
library(tidyverse)
library(scales)
library(sf)
library(usmap)

# ---- data ------------------------------------------------------------------
votes <- read_csv(
  "https://euclid.nmu.edu/~joshthom/dat309/week9/zdata/2024_US_County_Level_Presidential_Results.csv",
  col_types = cols(county_fips = col_character(), .default = col_guess())
) |>
  transmute(
    fips = str_pad(county_fips, 5, pad = "0"),
    county = str_c(county_name, ", ", state_name),
    harris = votes_dem,
    trump = votes_gop,
    total = total_votes,
    other = total - harris - trump,
    winner = if_else(harris > trump, "Harris", "Trump"),
    margin_votes = abs(harris - trump),
    margin_pct = 100 * margin_votes / total,
    harris_pct = 100 * harris / total,
    trump_pct = 100 * trump / total,
    other_pct = 100 * other / total
  )

# county shapes (sf, geometry column "geom"); AK and HI excluded.
# join on fips so county-name spelling differences can't break the match
us_map_sf <- us_map("counties", exclude = c("AK", "HI")) |>
  select(fips, geom) |>
  left_join(votes, by = "fips")

# nationwide totals (lower 48 only, to match the map), shown before any click
national <- votes |>
  filter(fips %in% us_map_sf$fips) |>
  summarize(
    county = "United States (excluding AK & HI)",
    across(c(harris, trump, other, total), sum)
  ) |>
  mutate(
    harris_pct = 100 * harris / total,
    trump_pct = 100 * trump / total,
    other_pct = 100 * other / total,
    winner = if_else(harris > trump, "Harris", "Trump"),
    margin_votes = abs(harris - trump),
    margin_pct = 100 * margin_votes / total
  )

party_colors <- c(Harris = "#00AEF3", Trump = "#E81B23")

# ---- ui --------------------------------------------------------------------
ui <- page_fillable(
  titlePanel(h1(
    "US Presidential Election Results 2024",
    align = "center"
  )),
  layout_columns(
    col_widths = c(8, 4),
    card(
      card_header("Click a county"),
      plotOutput("map", click = "map_click", height = "650px")
    ),
    card(
      card_header(textOutput("county_name")),
      layout_column_wrap(
        width = 1 / 2,
        value_box(title = "Winner", value = textOutput("winner_text")),
        value_box(title = "Margin", value = textOutput("margin_text")),
        value_box(
          title = "Harris",
          value = textOutput("harris_text"),
          theme = value_box_theme(bg = party_colors[["Harris"]], fg = "white")
        ),
        value_box(
          title = "Trump",
          value = textOutput("trump_text"),
          theme = value_box_theme(bg = party_colors[["Trump"]], fg = "white")
        )
      ),
      tableOutput("stats_table")
    )
  )
)

# ---- server ----------------------------------------------------------------
server <- function(input, output, session) {
  # reactiveVal so the selection survives the plot re-draw
  selected <- reactiveVal(NULL)

  # st_sfc() creates a simple feature geometry list-column (sf) object from the click coordinates
  # st_point() creates a simple feature point geometry (sfg) object from the click coordinates
  # st_crs() gets the coordinate reference system (CRS) of the us_map_sf object
  observeEvent(input$map_click, {
    pt <- st_sfc(
      st_point(c(input$map_click$x, input$map_click$y)),
      crs = st_crs(us_map_sf)
    )
    # st_intersects() finds the intersection between the map and the click
    hit <- us_map_sf[st_intersects(us_map_sf, pt, sparse = FALSE)[, 1], ]
    # clicking off the map (or on a county with no data) resets to national
    selected(if (nrow(hit) == 1 && !is.na(hit$total)) hit else NULL)
  })

  # current() returns the selected county, or national if none is selected
  current <- reactive({
    if (is.null(selected())) national else st_drop_geometry(selected())
  })

  output$map <- renderPlot({
    p <- ggplot(us_map_sf) +
      geom_sf(aes(fill = winner), color = "grey90", linewidth = 0.05) +
      scale_fill_manual(values = party_colors, na.value = "grey80") +
      labs(fill = "Winner") +
      theme_void() +
      theme(legend.position = "bottom", legend.text = element_text(size = 12))

    if (!is.null(selected())) {
      p <- p +
        geom_sf(data = selected(), fill = NA, color = "black", linewidth = 1)
    }
    p
  })

  output$county_name <- renderText(current()$county)
  output$winner_text <- renderText(current()$winner)

  output$margin_text <- renderText({
    str_c(
      percent(current()$margin_pct / 100, accuracy = 0.1),
      " (",
      comma(current()$margin_votes),
      " votes)"
    )
  })

  output$harris_text <- renderText(percent(
    current()$harris_pct / 100,
    accuracy = 0.1
  ))
  output$trump_text <- renderText(percent(
    current()$trump_pct / 100,
    accuracy = 0.1
  ))

  output$stats_table <- renderTable(
    {
      cur <- current()
      tibble(
        Candidate = c("Harris", "Trump", "Other", "Total"),
        Votes = comma(c(cur$harris, cur$trump, cur$other, cur$total)),
        Percent = percent(
          c(cur$harris_pct, cur$trump_pct, cur$other_pct, 100) / 100,
          accuracy = 0.1
        )
      )
    },
    align = "lrr"
  )
}

shinyApp(ui = ui, server = server)
