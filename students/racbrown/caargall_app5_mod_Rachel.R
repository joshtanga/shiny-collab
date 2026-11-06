# ------------------------------------------------------------
# App:        caargall_app5.R
# Author:     Carson Argall
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - Added checkboxes to choose species
#   - Added renderText() to show what species is selected
# ------------------------------------------------------------


library(shiny)
library(tidyverse)
library(bslib)
library(plotly)
library(palmerpenguins)
 
# ui ---------------------------------------------------------
ui <- page_sidebar(
  theme = bs_theme(bootswatch = "flatly"),
  title = "Filtering bill depth with slider with plotly",
  sidebar = sidebar(
    input_dark_mode(),
    sliderInput("bill_depth",
                "Set bill depth",
                min = 13.1,
                max = 21.5,
                value = 15),
    selectInput("sex",
                "Choose sex",
                choices = c("male", "female"),
                selected = "female"),
    checkboxGroupInput("species",
                       "Choose Species",
                       choices = c("Adelie", "Chinstrap", "Gentoo"),
                       selected = c("Adelie", "Chinstrap", "Gentoo")),
    downloadButton("dl", "Download CSV")
  ),
  navset_card_tab(
    nav_panel("Plot", plotlyOutput("graph")),
    nav_panel("Table", tableOutput("table"))
  ),
  card(
    card_body(
      textOutput("speciesSelected"),
      textOutput("summary")
    )
  )
)
 
# server -----------------------------------------------------
server <- function(input, output) {
 
  # one shared filtered dataset used by the plot, table, and summary
  filtered <- reactive({
    penguins |>
      filter(bill_depth_mm < input$bill_depth,
             sex == input$sex,
             species %in% input$species)
  })
 
  output$graph <- renderPlotly({
    plot_ly(filtered(),
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species,
            type = "scatter3d",
            mode = "markers") |>
      layout(
        paper_bgcolor = "rgba(0,0,0,0)",
        scene = list(xaxis = list(title = "Body Mass"),
                     yaxis = list(title = "Bill Length"),
                     zaxis = list(title = "Flipper Length"))
      )
  })
 
  output$summary <- renderText({
    str_c("Showing ", nrow(filtered()), " of ", nrow(penguins), " rows; ",
          "mean body mass = ", round(mean(filtered()$body_mass_g, na.rm = TRUE), 1))
  })
 
  output$speciesSelected <- renderText({
    paste("Species Selected:", paste(input$species, collapse = ", "))
  })
 
  output$table <- renderTable({
    filtered() |>
      arrange(desc(body_mass_g)) |>
      transmute(body_mass = body_mass_g,
                bill_length = bill_length_mm,
                flipper_length = flipper_length_mm,
                species = species)
  })
 
  # download the currently filtered data as a CSV
  output$dl <- downloadHandler(
    filename = "filtered.csv",
    content = function(file) write_csv(filtered(), file)
  )
}
 
shinyApp(ui = ui, server = server)
 