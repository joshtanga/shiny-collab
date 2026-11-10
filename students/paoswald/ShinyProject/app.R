# Library
library(shiny)
library(bslib)
library(tidyverse)
library(janitor)

# Importing Data and Cleaning it
temperature <- read_csv("annual-temperaturenew.csv") |>
  clean_names() |>
  rename(country = countey)
# looked for na values and found none.
# did a glimpse(temperature) to check variables
# renamed country 

ui <- page_sidebar( # page with a sidebar for controls


  # Side Bar
  
  title = "Global Temperature Explorer",
  sidebar = sidebar(
    p("Select a country and year to explore temperature data"),

    # Choices for Sidebar
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
    )
  ),
  # Creates hte location for the plot
  plotOutput("temperature_plot")

)

server <- function(input,output){
  # creating my temperature plot
  output$temperature_plot <- renderPlot({

    req(input$country1, input$country2)

    #making sure the ggplot grabs the selected data
    selected <- temperature |> 
      filter(country %in% c(input$country1, input$country2))

    #making the ggplot
    ggplot(selected,
      aes(x = year, y = temperature_anomaly, color = country)) +
      geom_line() + 
      labs(
        title = "Temperature Anomalies Over Time",
        x = "Year",
        y = "Temperature Anomaly (°C)"
      ) +
      theme_minimal()


  })

}

# Run the application 
shinyApp(ui = ui, server = server)