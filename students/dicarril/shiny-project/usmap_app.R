# loading shiny and getting started with basics

library(shiny)
library(tidyverse)
library(bslib)
library(usmap)
library(scales)

# Store the county population data
county_pop <- usmap::countypop

ui <- page_fillable(
  
  title = "United States County Population",
  
  # Card containing the two filters
  card(
    card_header("Map Filters"),
    layout_columns( col_widths = c(6,6),
    sliderInput(
      "pop",
      "County Population range:",
      min = min(county_pop$pop_2022),
      max = max(county_pop$pop_2022),
      value = range(county_pop$pop_2022),
      step = 10000
    ),
    
    textInput(
      "county",
      "Search for a county:",
      placeholder = "Example: Marquette"
    )
  ),
  
  # Card containing the map
  card(
    full_screen = TRUE,
    card_header("County Population Map"),
    plotOutput("map", height = "600px")
  )
)
)

server <- function(input, output) {
  
  # Filter counties using the population slider and county search
data <- reactive({
  
  # Begin with the complete county population dataset.
  # Keep counties whose 2022 population falls between the
  # minimum and maximum values selected with the slider.
  filtered <- county_pop |>
    filter(
      pop_2022 >= input$pop[1],
      pop_2022 <= input$pop[2]
    )
  # input$pop[1] is the lower end of the population slider.
  # input$pop[2] is the upper end of the population slider.
  
  # Only filter by county name when the search box is not empty.
  if (input$county != "") {
    
    filtered <- filtered |>
      filter(
        str_detect(
          # Convert county names to lowercase so the search
          # is not affected by capitalization.
          str_to_lower(county),
          # Convert the user's search to lowercase and treat
          # it as regular text instead of a pattern.
          fixed(str_to_lower(input$county))
        )
      )
  }
  
  # Return the filtered dataset from the reactive expression.
  filtered
})

# Create the map and update it whenever data() changes.
output$map <- renderPlot({
  
  # Check whether the filters produced at least one county.
  validate(
    need(
      
      # data() retrieves the current reactive dataset.
      # nrow() counts how many counties remain.
      nrow(data()) > 0,
      
      # Display this message if no counties match the filters.
      "No counties match the selected filters."
    )
  )
})
  
  # Create the map
  output$map <- renderPlot({
    
    validate(
      need(
        nrow(data()) > 0,
        "No counties match the selected filters."
      )
    )
    
    plot_usmap(
      regions = "counties",
      exclude = c("AK", "HI"),
      data = data(),
      values = "pop_2022",
      color = "white",
      linewidth = 0.1 
    ) +
      scale_fill_viridis_c(
        name = "Population",
        transform = "log10",
        labels = scales::label_comma(),
        na.value = "gray90"
      ) +
      labs(
        title = "United States County Population"
      ) +
      theme(
        legend.position = "right"
      )
  })
}

shinyApp(ui = ui, server = server)