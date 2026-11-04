# Feature Relay: draw a Shiny feature card, decide if it fits, add it
library(shiny)
library(bslib)

# ---- the deck ----------------------------------------------------------------
# each card: name, category, when to use it, when to skip it, starter code
card_deck <- list(
  list(
    name = "value_box()", cat = "Output",
    use = "One number matters most: a total, an average, or how many rows are shown.",
    skip = "You need to compare many values. Use a chart instead.",
    code = '# ui
value_box(title = "Penguins shown", value = textOutput("n_shown"))

# server
output$n_shown <- renderText(nrow(filtered()))'
  ),
  list(
    name = "dateRangeInput()", cat = "Input",
    use = "Your data has a real Date column and users care about a time window.",
    skip = "There are no dates. Years stored as numbers work better with a range slider.",
    code = '# ui
dateRangeInput("dates", "Dates", start = min(df$date), end = max(df$date))

# server
filter(df, between(date, input$dates[1], input$dates[2]))'
  ),
  list(
    name = "Range slider: sliderInput(value = c(lo, hi))", cat = "Input",
    use = "Users should keep only rows within a numeric range (years, prices, sizes).",
    skip = "The variable is a category, not a number.",
    code = '# ui
sliderInput("yrs", "Years", min = 1950, max = 2020,
            value = c(1980, 2000), sep = "")

# server
filter(df, between(year, input$yrs[1], input$yrs[2]))'
  ),
  list(
    name = "checkboxGroupInput()", cat = "Input",
    use = "Users pick SEVERAL of a FEW categories to compare (roughly 2 to 8).",
    skip = "There are dozens of categories. Use selectInput(multiple = TRUE).",
    code = '# ui
checkboxGroupInput("sp", "Species",
  choices = levels(penguins$species),
  selected = levels(penguins$species))

# server
filter(penguins, species %in% input$sp)'
  ),
  list(
    name = "selectInput(multiple = TRUE)", cat = "Input",
    use = "There are many categories (counties, countries, teams) and users pick a few.",
    skip = "There are only 2 or 3 choices. Checkboxes or radio buttons are clearer.",
    code = '# ui
selectInput("counties", "Counties",
  choices = sort(unique(df$county)), multiple = TRUE)

# server
filter(df, county %in% input$counties)'
  ),
  list(
    name = "radioButtons() to switch views", cat = "Input",
    use = "There are two ways to show the same thing (counts vs. percents, linear vs. log).",
    skip = "Both views should be seen at the same time. Use tabs or two plots.",
    code = '# ui
radioButtons("show", "Show", c("Count", "Percent"), inline = TRUE)

# server
ggplot(df, aes(x = island, fill = species)) +
  geom_bar(position = if (input$show == "Percent") "fill" else "stack")'
  ),
  list(
    name = "checkboxInput() to toggle a layer", cat = "Input",
    use = "An extra layer (a trend line, labels, a reference line) is useful but optional.",
    skip = "The layer should always be there. Then just add it.",
    code = '# ui
checkboxInput("trend", "Show trend line", value = FALSE)

# server
p <- ggplot(df, aes(x, y)) + geom_point()
if (input$trend) p <- p + geom_smooth(method = "lm")
p'
  ),
  list(
    name = "numericInput()", cat = "Input",
    use = "Users need an EXACT number: a sample size, a threshold, a top-N.",
    skip = "Rough values are fine and a slider is easier to use.",
    code = '# ui
numericInput("top_n", "How many to show?", value = 10, min = 1, max = 50)

# server
df |> slice_max(value, n = input$top_n)'
  ),
  list(
    name = "Plot click + nearPoints()", cat = "Interaction",
    use = "Individual rows matter (cars, counties, players) and users want details on one.",
    skip = "The plot shows summaries (bars, boxplots) or thousands of overlapping points.",
    code = '# ui
plotOutput("plot", click = "plot_click")

# server  (keep the selection in a reactiveVal: see bug10!)
picked <- reactiveVal(df[0, ])
observeEvent(input$plot_click, {
  hit <- nearPoints(df, input$plot_click, maxpoints = 1)
  if (nrow(hit) > 0) picked(hit)
})'
  ),
  list(
    name = "Plot brush + brushedPoints()", cat = "Interaction",
    use = "Users want to select a REGION of a scatterplot and see those rows.",
    skip = "There's no scatterplot, or there are only a handful of points.",
    code = '# ui
plotOutput("plot", brush = "plot_brush")
tableOutput("selected")

# server
output$selected <- renderTable(brushedPoints(df, input$plot_brush))'
  ),
  list(
    name = "plotly hover: ggplotly()", cat = "Interaction",
    use = "There are many points and hovering to see a name or value helps.",
    skip = "The plot is simple, or it's an sf map (slow in plotly).",
    code = '# ui
plotly::plotlyOutput("p")

# server
output$p <- plotly::renderPlotly({
  g <- ggplot(df, aes(x, y, text = name)) + geom_point()
  plotly::ggplotly(g, tooltip = "text")
})'
  ),
  list(
    name = "DT table: DTOutput()", cat = "Output",
    use = "Users want to browse, search or sort the actual rows.",
    skip = "It's a small summary table. tableOutput() is enough.",
    code = '# ui
DT::DTOutput("tbl")

# server
output$tbl <- DT::renderDT(filtered())'
  ),
  list(
    name = "A summary sentence: textOutput()", cat = "Output",
    use = "A one-line summary helps the user read the plot: what's shown, n, the average.",
    skip = "The sentence would just repeat the plot title.",
    code = '# ui
textOutput("summary")

# server
output$summary <- renderText({
  str_c("Showing ", nrow(filtered()), " of ", nrow(df), " rows; ",
        "mean = ", round(mean(filtered()$value, na.rm = TRUE), 1))
})'
  ),
  list(
    name = "downloadButton() + downloadHandler()", cat = "Output",
    use = "Users will want to keep the filtered data (or the plot) you're showing them.",
    skip = "There's nothing worth exporting.",
    code = '# ui
downloadButton("dl", "Download CSV")

# server
output$dl <- downloadHandler(
  filename = "filtered.csv",
  content = function(file) write_csv(filtered(), file)
)'
  ),
  list(
    name = "Map: geom_sf()", cat = "Output",
    use = "The data is about places with shapes (counties, states) and you can join it to them.",
    skip = "There's no location column, or location isn't part of the question.",
    code = '# outside server: join your data to shapes by an ID (e.g. fips)
map_df <- shapes |> left_join(my_data, by = "fips")

# server
ggplot(map_df) +
  geom_sf(aes(fill = value), color = "white") +
  theme_void()'
  ),
  list(
    name = "Map: leaflet", cat = "Output",
    use = "The data has latitude/longitude points and users want to zoom and pan.",
    skip = "There are no coordinates, or a static map tells the story.",
    code = '# ui
leaflet::leafletOutput("map")

# server
output$map <- leaflet::renderLeaflet({
  leaflet::leaflet(df) |>
    leaflet::addTiles() |>
    leaflet::addCircleMarkers(~lon, ~lat, popup = ~name)
})'
  ),
  list(
    name = "Tabs: navset_card_tab()", cat = "Layout",
    use = "There are several views of the same data (plot, table, map) and too little room to show them all.",
    skip = "There's only one view. Tabs would hide it behind a click.",
    code = '# ui
navset_card_tab(
  nav_panel("Plot",  plotOutput("p")),
  nav_panel("Table", tableOutput("t"))
)'
  ),
  list(
    name = "accordion() in the sidebar", cat = "Layout",
    use = "The sidebar has many inputs. Group them so it isn't a wall of controls.",
    skip = "There are only 2 or 3 inputs.",
    code = '# ui
sidebar = sidebar(
  accordion(
    accordion_panel("Filters", selectInput(...), sliderInput(...)),
    accordion_panel("Display", checkboxInput(...))
  )
)'
  ),
  list(
    name = "conditionalPanel()", cat = "Layout",
    use = "An input only makes sense in some situations (bins only for a histogram).",
    skip = "The input always matters.",
    code = '# ui  (the condition is JavaScript: input.id, not input$id)
radioButtons("type", "Plot type", c("Histogram", "Boxplot")),
conditionalPanel(
  "input.type == \'Histogram\'",
  sliderInput("bins", "Bins", min = 5, max = 50, value = 20)
)'
  ),
  list(
    name = "One shared reactive()", cat = "Reactivity",
    use = "Two or more outputs use the same filtered data.",
    skip = "There's only one output. (But it's still a good habit.)",
    code = '# server
filtered <- reactive({
  df |> filter(species %in% input$sp)
})

output$plot  <- renderPlot(ggplot(filtered(), ...))
output$table <- renderTable(filtered())'
  ),
  list(
    name = "actionButton() + eventReactive()", cat = "Reactivity",
    use = "Something is random, slow, or should only happen on demand (\"Update\").",
    skip = "Results should update instantly as inputs change.",
    code = '# ui
actionButton("go", "Update")

# server
results <- eventReactive(input$go, {
  slow_or_random_thing(input$n)
}, ignoreNULL = FALSE)'
  ),
  list(
    name = "reactiveVal()", cat = "Reactivity",
    use = "The app must REMEMBER something between clicks: a selection, a list of favorites.",
    skip = "The value can always be computed from the current inputs.",
    code = '# server
favorites <- reactiveVal(character())

observeEvent(input$add, {
  favorites(c(favorites(), input$item))
})

output$favs <- renderText(paste(favorites(), collapse = ", "))'
  ),
  list(
    name = "validate(need())", cat = "Polish",
    use = "A filter can return 0 rows, or an input can be empty.",
    skip = "Never skip it if users can filter everything away!",
    code = '# server, at the top of a render*()
validate(
  need(nrow(filtered()) > 0, "No rows match. Try widening your filters.")
)'
  ),
  list(
    name = "Theme + dark mode", cat = "Polish",
    use = "The app works and you want it to look finished.",
    skip = "The app doesn't work yet. Polish comes last.",
    code = '# ui
page_sidebar(
  theme = bs_theme(bootswatch = "flatly"),
  title = "My app",
  sidebar = sidebar(input_dark_mode(), ...),
  ...
)'
  )
)

cat_colors <- c(
  Input = "primary", Output = "success", Interaction = "warning",
  Layout = "info", Reactivity = "danger", Polish = "secondary"
)

# ---- ui --------------------------------------------------------------------
ui <- page_sidebar(
  title = "Shiny Feature Relay",
  sidebar = sidebar(
    width = 340,
    actionButton("draw", "Draw a card", class = "btn-primary btn-lg"),
    textOutput("deck_status"),
    accordion(
      open = "How to play",
      accordion_panel(
        "How to play",
        tags$ol(
          tags$li(tags$code("git pull"), ". Then copy the app you're handed into your folder:",
                  tags$br(), tags$code("students/<you>/relay<round>_<author>.R")),
          tags$li("Draw a card. Read ", tags$b("use it when"), " and ", tags$b("skip it when"), "."),
          tags$li(tags$b("Fits the data?"), " Add the feature to the app."),
          tags$li(tags$b("Doesn't fit?"), " Write one comment saying why, then draw again. ",
                  "You get 2 redraws; the 3rd card must be used."),
          tags$li("Update the header comment: round, original author, cards drawn, what you added."),
          tags$li("Run it, then ", tags$code("git add"), ", ", tags$code("git commit"), ", ",
                  tags$code("git pull"), ", ", tags$code("git push"), ".")
        ),
        p(tags$b("Next round:"), " take the file the next person on the class list made last round, ",
          "and do it again. Each app collects one new feature per round.")
      ),
      accordion_panel(
        "Header template",
        tags$pre(
          "# Relay round: 2
# Started from: students/jmorton/relay1_paoswald.R
# Cards drawn: DT table (skipped: data is only 3 rows),
#              value_box()
# Added: value box showing the average body mass"
        )
      ),
      accordion_panel(
        "Commit message",
        tags$pre("relay2: add value_box (avg body mass)"),
        p("Say what you added, so the git history tells the story of the app.")
      )
    )
  ),
  uiOutput("feature_card"),
  card(
    card_header("Drawn so far"),
    textOutput("history")
  )
)

# ---- server ----------------------------------------------------------------
server <- function(input, output, session) {
  # cards not yet drawn (a shuffled deck), and the card on the table
  deck <- reactiveVal(sample(seq_along(card_deck)))
  current <- reactiveVal(NULL)
  drawn <- reactiveVal(character())

  observeEvent(input$draw, {
    # reshuffle when the deck runs out
    if (length(deck()) == 0) deck(sample(seq_along(card_deck)))
    current(card_deck[[deck()[1]]])
    deck(deck()[-1])
    drawn(c(drawn(), current()$name))
  })

  output$deck_status <- renderText({
    paste(length(deck()), "of", length(card_deck), "cards left in the deck")
  })

  output$feature_card <- renderUI({
    f <- current()
    if (is.null(f)) {
      return(card(
        card_header("Ready?"),
        p("Click ", tags$b("Draw a card"), " to get a Shiny feature."),
        p("Then decide: does it fit the data and the question of the app you're holding?")
      ))
    }
    card(
      card_header(
        span(class = paste0("badge bg-", cat_colors[[f$cat]], " me-2"), f$cat),
        tags$code(style = "font-size: 1.3em;", f$name)
      ),
      layout_columns(
        col_widths = c(6, 6),
        div(h5("Use it when"), p(f$use)),
        div(h5("Skip it when"), p(f$skip))
      ),
      h5("Starter code"),
      tags$pre(f$code)
    )
  })

  output$history <- renderText({
    if (length(drawn()) == 0) "Nothing yet." else paste(drawn(), collapse = "  |  ")
  })
}

shinyApp(ui, server)
