# showcase of 'using a table in Shiny' using the DT package
# this shiny app displays a table of the 2024 US presidential election results by county
# using the DT package to make the table sortable and searchable (datatable)

library(shiny)
library(bslib)
library(tidyverse)
library(DT)


# expecting the app to be run from the shiny-collab/starter-code directory,
# so the data load file is up one directory in the starter-code subdirectory
source('../starter-code/election_data_2024_load.R')

# select & clean up columns for display in the table
edf <- edf |>
  select(
    state_name,
    county_name,
    votes_dem,
    votes_gop,
    total_votes,
    pop_dens,
    winner
  ) |>
  rename(
    State = state_name,
    County = county_name,
    Harris = votes_dem,
    Trump = votes_gop,
    Total = total_votes,
    Density = pop_dens,
    Winner = winner
  )

ui <- page_sidebar(
  title = "2024 US Presidential Election Results",
  align = "center",
  sidebar = sidebar(
    selectInput(
      "state",
      "Select a state:",
      choices = sort(unique(edf$State)),
      selected = "Michigan"
    )
  ),
  card(
    DTOutput("tbl")
  )
)

server <- function(input, output, session) {
  filtered_data <- reactive({
    edf |> filter(State == input$state)
  })
  output$tbl <- renderDT({
    datatable(filtered_data()) |>
      # the above is all you basically need, below makes
      # it look nicer with commas and rounding
      formatRound(
        c("Trump", "Harris", "Total", "Density"),
        digits = 0
      )
  })
}

shinyApp(ui = ui, server = server)
