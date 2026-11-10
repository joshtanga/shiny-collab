# loading shiny and getting started with basics

library(shiny)
library(tidyverse)
library(bslib)
library(usmap)
library(scales)
library(shinythemes)

# Store the county poverty data
source("load.R")

ui <- page_fillable(
  
  title = "United States County Poverty",
  theme = bs_theme(version = 5, bootswatch = "slate"),

  tags$style(
    HTML(
      "
      .card-header {
        color: white !important;
      }
      "
    )
  ),


layout_columns(
  col_widths = c(3,9),
  # Dividing the page in half
  div(
  # Card containing the filters
    card(
      card_header("Map Filters"),
        sliderInput(
          "poverty",
          "Poverty Rate:",
          min = min(county_data$poverty_rate),
          max = max(county_data$poverty_rate),
          value = range(county_data$poverty_rate),
          step = 0.5, 
          post = "%"
        ),

      # Filter counties by state
      selectInput(
        "state",
        "Select a state:",
        choices = c(
          "All states" = "All",
          sort(unique(county_data$state))
        ),
        selected = "All"
      ),

      # County search bar
      textInput(
        "county",
        "Search for a county:",
        placeholder = "Example: Marquette", 
      ),

      br(),
    
      # Total number of counties being displayed
      value_box(
        title = "Counties shown",
        value = textOutput("n_counties"), 
        theme = "info"
      ),
      # Average poverty rate for the current filter
      value_box(
        title = "Average poverty rate",
        value = textOutput("avg_poverty"), 
        theme = "warning"
      )
    )
  ),
  

  # Creating the other half of the page
  div(
  # Card containing the map
    card(
      card_header("County Poverty Map"),
      plotOutput("map", height = "600px")
    ),

    br(),
    # Display summary table under map
    card(
      card_header("Top Ten Counties With the Highest Poverty Rates"),
      tableOutput("county_table")
    )
   )
  )
)


server <- function(input, output) {
  
  # Filter counties using the poverty slider and county search
filtered_counties <- reactive({
  
  # Keep counties within the selected poverty-rate range
  filtered <- county_data |>
    filter(
      poverty_rate >= input$poverty[1],
      poverty_rate <= input$poverty[2]
    )
  # input$poverty[1] is the lower end of the population slider.
  # input$poverty[2] is the upper end of the population slider.
  
  # Apply the state filter unless all states are selected
    if (input$state != "All") {
      filtered <- filtered |>
        filter(state == input$state)
    }
  

# Remove extra spaces from the county search
    county_search <- str_trim(input$county)
    
    # Apply the county search only when text is entered
    if (county_search != "") {
      filtered <- filtered |>
        filter(
          str_detect(
            str_to_lower(county),
            fixed(str_to_lower(county_search))
          )
        )
    }
    
    filtered
  })

  # Show the average poverty rate among selected counties
output$avg_poverty <- renderText({
  
  validate(
    need(
      nrow(filtered_counties()) > 0,
      "No data"
    )
  )
  
  paste0(
    round(mean(filtered_counties()$poverty_rate), 1),
    "%"
  )
})

  # Show the number of counties meeting the filters
  output$n_counties <- renderText({
    comma(nrow(filtered_counties()))
  })
  
  # Show the ten highest poverty rates among filtered counties
  output$county_table <- renderTable({
    filtered_counties() |>
      arrange(desc(poverty_rate)) |>
      slice_head(n = 10) |>
      select(county, state, poverty_count, poverty_rate) |>
      mutate(
        poverty_count = comma(poverty_count),
        poverty_rate = paste0(round(poverty_rate, 1), "%")
      ) |>
      rename(
        "County" = county,
        "State" = state,
        "People in poverty" = poverty_count,
        "Poverty rate" = poverty_rate
      )
  })
  
  # Draw the map using the current filtered dataset
  output$map <- renderPlot({
    
    validate(
      need(
        nrow(filtered_counties()) > 0,
        "No counties match the selected filters."
      )
    )
    
    plot_usmap(
      regions = "counties",
      data = filtered_counties(),
      values = "poverty_rate",
      color = "grey90",
      linewidth = 0.1
    ) +
      scale_fill_viridis_c(
        name = "Poverty rate",
        labels = label_number(suffix = "%"),
        na.value = "gray90"
      ) +
      labs(
        title = "County Poverty Rates in the United States",
        subtitle = "Counties outside the selected filters appear gray",
        caption = "Source: USDA Economic Research Service, 2023"
      ) +
      theme(
        legend.position = "right",
        plot.title = element_text(face = "bold")
      )
  })

}
shinyApp(ui = ui, server = server)