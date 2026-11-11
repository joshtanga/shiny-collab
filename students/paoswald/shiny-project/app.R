# Library
library(shiny)
library(bslib)
library(tidyverse)
library(janitor)

# Importing Data and Cleaning it
temperature <- read_csv("annual-temperaturenew.csv") |>
  clean_names() |>
  rename(country = countey)
# checking the column types
glimpse(temperature)
# checking for na values
print(colSums((is.na(temperature))))

ui <- page_sidebar( # page with a sidebar for controls
  fillable = FALSE,

  # Side Bar
  title = "Global Temperature Explorer",
  sidebar = sidebar(
    p("Select a country and year to explore temperature data"),

    # Country Selector Dropdown
    #Country 1
    selectInput(
      "country1",
      "Select First Country:",
      choices = sort(unique(temperature$country))
    ),

    # Creating a second selection so that you can compare countries
    selectInput(
      "country2",
      "Select Second Country:",
      choices = sort(unique(temperature$country)),
      selected = "Canada"
    ),

  # Slider for selecting the year
  sliderInput(
    "years",
    "Select Year Range:",
    min = min(temperature$year),
    max = max(temperature$year),
    value = c(min(temperature$year), max(temperature$year)),
    step = 1
  )
  ),

  # Creates the location for the plot, stats table, and data preview
  plotOutput("temperature_plot", width = "100%", height = "600px"),
  h3("Summary Statistics"),
  tableOutput("summary_stats"),
  h3("Temperature Data Preview"),
  tableOutput("data_prev")

)



server <- function(input,output){
  # Selecting data to be used, making it required to create the graph
    selected <- reactive({
    req(input$country1, input$country2, input$years)

    #making sure the ggplot grabs the selected data
      temperature |> 
      filter(
        country %in% c(input$country1, input$country2),
        year >= input$years[1],
        year <= input$years[2]
      )
    })

  output$temperature_plot <- renderPlot({
    #making the ggplot
    ggplot(selected(),
      aes(x = year, y = temperature_anomaly, color = country)) +
      geom_line() + 
      labs(
        title = "Temperature Anomalies Over Time",
        x = "Year",
        y = "Temperature Anomaly (°C)"
      ) +
      theme_minimal() +
      theme(plot.margin = margin(5, 5, 5, 5))


  }, execOnResize = TRUE)

  # Summary Statistics table
  output$summary_stats <- renderTable({
    selected() |>
      group_by(country) |>
      summarise(
        Average = mean(temperature_anomaly),
        Minimum = min(temperature_anomaly),
        Maximum = max(temperature_anomaly)
      )
  })

  # Data Preview
  output$data_prev <- renderTable({
    head(selected(), 10)
  })

}
# Run the application 
shinyApp(ui = ui, server = server)