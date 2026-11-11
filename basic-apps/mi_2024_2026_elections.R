# Michigan election results by county: 2024 president and 2026 races
# pick an election, then click a county to see its results
# run from the shiny-collab folder (the source() paths below start there)

# ---- data ------------------------------------------------------------------
# 2024: votes (president by county), mi_map (county shapes)
source("basic-apps/load_data_mi_2024.R")
mi_map <- mi_map |> mutate(year = 2024)

# 2026: mi26 (one row per county and office, with Democratic / Republican / Other votes)
source("basic-apps/load_data_mi_2026.R")

# county shapes; county names without " County" so they match the 2026 data
shapes <- mi_map |>
  select(county) |>
  mutate(county = str_remove(county, " County"))

# put both years in the same shape: one row per county per election,
# with Democratic, Republican and other votes
results_2024 <- votes |>
  transmute(
    county = str_remove(county, " County"),
    election = "2024 President",
    dem = harris,
    rep = trump,
    other = other
  )

results_2026 <- mi26 |>
  ungroup() |>
  mutate(
    election = case_when(
      str_starts(office, "Governor And") ~ "2026 Governor",
      str_starts(office, "United States Senator") ~ "2026 U.S. Senate",
      str_starts(office, "Representative In Congress") ~ "2026 U.S. House",
      str_starts(office, "State Senator") ~ "2026 State Senate",
      str_starts(
        office,
        "Representative In State Legislature"
      ) ~ "2026 State House"
    )
  ) |>
  filter(!is.na(election)) |>
  transmute(county, election, dem = Democratic, rep = Republican, other = Other)

# percentages, margin and winner, computed the same way for every election
add_stats <- function(df) {
  df |>
    mutate(
      # a race with no Democrat (or Republican) on the ballot has NA votes
      across(c(dem, rep, other), \(x) replace_na(x, 0)),
      total = dem + rep + other,
      dem_pct = 100 * dem / total,
      rep_pct = 100 * rep / total,
      other_pct = 100 * other / total,
      margin_votes = abs(dem - rep),
      margin_pct = 100 * margin_votes / total,
      winner = case_when(
        dem > rep ~ "Democratic",
        rep > dem ~ "Republican",
        .default = "Tie"
      )
    )
}

results <- bind_rows(results_2024, results_2026) |>
  add_stats()

# statewide totals for each election, shown before a county is clicked
# (for House and legislature races, this adds up all the districts)
statewide <- results |>
  group_by(election) |>
  summarize(
    county = "Michigan (statewide)",
    across(c(dem, rep, other), sum)
  ) |>
  add_stats()

# candidate names for the statewide races; district races show the party instead
candidate_names <- tribble(
  ~election          , ~dem_name  , ~rep_name ,
  "2024 President"   , "Harris"   , "Trump"   ,
  "2026 Governor"    , "Benson"   , "James"   ,
  "2026 U.S. Senate" , "El-Sayed" , "Rogers"
)

elections <- c(
  "2024 President",
  "2026 Governor",
  "2026 U.S. Senate",
  "2026 U.S. House",
  "2026 State Senate",
  "2026 State House"
)

party_colors <- c(Democratic = "#00AEF3", Republican = "#E81B23")

# from https://fontawesome.com/icons/classic/light/democrat
democrat_icon <- tags$div(
  style = "width: 2.5rem; height: 2.5rem; fill: currentColor;",
  HTML(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Free v7.3.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path d="M64 96C64 87.1 67.8 75.1 70.2 68.7C71.2 65.9 74 64 77 64C78.9 64 80.8 64.7 82.2 66.1L128 109.7L173.8 66.1C175.2 64.8 177 64 179 64C182 64 184.8 65.8 185.8 68.7C188.2 75.2 192 87.1 192 96C192 122.5 170.1 138 162.5 142.6L238.7 215.2C244.7 220.9 252.6 224 260.8 224L480 224L512 224C552.3 224 590.2 243 614.4 275.2L633.6 300.8C644.2 314.9 641.3 335 627.2 345.6C613.1 356.2 593 353.3 582.4 339.2L563.2 313.6C557.9 306.6 551.4 300.8 544 296.6L544 384L192 384L151.6 289.7C147.7 280.5 136.3 277.1 128 282.7L85.9 310.7C76.8 316.8 66.2 320 55.2 320L53.2 320C23.9 320 0 296.1 0 266.7C0 254.6 4.1 242.9 11.7 233.4L87.6 138.6C78.1 131.4 64 117.2 64 96zM544 416L544 544C544 561.7 529.7 576 512 576L480 576C462.3 576 448 561.7 448 544L448 480L288 480L288 544C288 561.7 273.7 576 256 576L224 576C206.3 576 192 561.7 192 544L192 416L544 416zM256 344C269.3 344 280 333.3 280 320C280 306.7 269.3 296 256 296C242.7 296 232 306.7 232 320C232 333.3 242.7 344 256 344zM504 320C504 306.7 493.3 296 480 296C466.7 296 456 306.7 456 320C456 333.3 466.7 344 480 344C493.3 344 504 333.3 504 320zM368 344C381.3 344 392 333.3 392 320C392 306.7 381.3 296 368 296C354.7 296 344 306.7 344 320C344 333.3 354.7 344 368 344z"/></svg>'
  )
)

republican_icon <- tags$div(
  style = "width: 2.5rem; height: 2.5rem; fill: currentColor;",
  HTML(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Pro v7.3.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2026 Fonticons, Inc.--><path d="M0 256C0 167.6 71.6 96 160 96L384 96C472.4 96 544 167.6 544 256L544 320L0 320L0 256zM152 224C152 210.7 141.3 200 128 200C114.7 200 104 210.7 104 224C104 237.3 114.7 248 128 248C141.3 248 152 237.3 152 224zM384 248C397.3 248 408 237.3 408 224C408 210.7 397.3 200 384 200C370.7 200 360 210.7 360 224C360 237.3 370.7 248 384 248zM280 224C280 210.7 269.3 200 256 200C242.7 200 232 210.7 232 224C232 237.3 242.7 248 256 248C269.3 248 280 237.3 280 224zM128 352L544 352L544 464C544 472.8 551.2 480 560 480C568.8 480 576 472.8 576 464L576 416C576 398.3 590.3 384 608 384C625.7 384 640 398.3 640 416L640 464C640 508.2 604.2 544 560 544C515.8 544 480 508.2 480 464L480 416L448 416L448 512C448 529.7 433.7 544 416 544L352 544C334.3 544 320 529.7 320 512L320 448L128 448L128 512C128 529.7 113.7 544 96 544L32 544C14.3 544 0 529.7 0 512L0 352L128 352z"/></svg>'
  )
)

# ---- ui --------------------------------------------------------------------
ui <- page_fillable(
  titlePanel(h1("Michigan Election Results by County", align = "center")),
  selectInput("election", "Election", choices = elections),
  layout_columns(
    col_widths = c(7, 5),
    card(
      card_header("Click a county"),
      # click = "map_click" sends the click's x/y coordinates to input$map_click
      plotOutput("map", click = "map_click", height = "650px")
    ),
    card(
      card_header(textOutput("county_name")),
      layout_column_wrap(
        width = 1 / 2,
        value_box(title = "Winner", value = textOutput("winner_text")),
        value_box(title = "Margin", value = textOutput("margin_text")),
        value_box(
          title = textOutput("dem_name"),
          value = textOutput("dem_text"),
          showcase = democrat_icon,
          showcase_position = "right",
          theme = value_box_theme(
            bg = party_colors[["Democratic"]],
            fg = "white"
          )
        ),
        value_box(
          title = textOutput("rep_name"),
          value = textOutput("rep_text"),
          showcase = republican_icon,
          showcase_position = "right",
          theme = value_box_theme(
            bg = party_colors[["Republican"]],
            fg = "white"
          )
        )
      ),
      tableOutput("stats_table")
    )
  )
)

# ---- server ----------------------------------------------------------------
server <- function(input, output, session) {
  # the chosen election's results, joined to the county shapes for the map
  map_data <- reactive({
    shapes |>
      left_join(filter(results, election == input$election), by = "county")
  })

  # candidate names (or party names) for the chosen election
  names_now <- reactive({
    nm <- filter(candidate_names, election == input$election)
    if (nrow(nm) == 0) {
      list(dem = "Democratic", rep = "Republican")
    } else {
      list(dem = nm$dem_name, rep = nm$rep_name)
    }
  })

  # the selected county's NAME lives in a reactiveVal so it "sticks":
  # it survives the redraw that resets input$map_click to NULL, and it
  # stays selected when you switch to a different election
  selected <- reactiveVal(NULL)

  # on each click, find the county under the click and store its name
  # (observeEvent ignores the NULL that happens when the plot re-draws)
  observeEvent(input$map_click, {
    pt <- st_sfc(
      st_point(c(input$map_click$x, input$map_click$y)),
      crs = st_crs(shapes)
    )
    hit <- shapes$county[st_intersects(shapes, pt, sparse = FALSE)[, 1]]
    # clicking off the map clears the selection (back to statewide)
    selected(if (length(hit) == 1) hit else NULL)
  })

  # the row whose stats we display: the selected county, or statewide by default
  current <- reactive({
    if (is.null(selected())) {
      filter(statewide, election == input$election)
    } else {
      filter(results, election == input$election, county == selected())
    }
  })

  output$map <- renderPlot({
    p <- ggplot(map_data()) +
      geom_sf(
        aes(fill = winner, alpha = margin_pct),
        color = "white"
      ) +

      scale_alpha_continuous(
        range = c(0.15, 1),
        trans = "log10",
        name = "Margin Pct"
      ) +

      scale_fill_manual(values = party_colors, na.value = "grey80") +
      labs(fill = "Winner") +
      theme_void() +
      theme(legend.position = "bottom", legend.text = element_text(size = 12))

    # outline the selected county
    if (!is.null(selected())) {
      p <- p +
        geom_sf(
          data = filter(shapes, county == selected()),
          fill = NA,
          color = "black",
          linewidth = 1.2
        )
    }
    p
  })

  output$county_name <- renderText(str_c(
    current()$county,
    ": ",
    input$election
  ))

  output$winner_text <- renderText({
    w <- current()$winner
    case_when(
      w == "Democratic" ~ names_now()$dem,
      w == "Republican" ~ names_now()$rep,
      .default = w
    )
  })

  output$margin_text <- renderText({
    str_c(
      percent(current()$margin_pct / 100, accuracy = 0.1),
      " (",
      comma(current()$margin_votes),
      " votes)"
    )
  })

  output$dem_name <- renderText(names_now()$dem)
  output$rep_name <- renderText(names_now()$rep)

  output$dem_text <- renderText(percent(
    current()$dem_pct / 100,
    accuracy = 0.1
  ))
  output$rep_text <- renderText(percent(
    current()$rep_pct / 100,
    accuracy = 0.1
  ))

  output$stats_table <- renderTable(
    {
      cur <- current()
      tibble(
        Candidate = c(names_now()$dem, names_now()$rep, "Other", "Total"),
        Votes = comma(c(cur$dem, cur$rep, cur$other, cur$total)),
        Percent = percent(
          c(cur$dem_pct, cur$rep_pct, cur$other_pct, 100) / 100,
          accuracy = 0.1
        )
      )
    },
    align = "lrr"
  )
}

shinyApp(ui = ui, server = server)
