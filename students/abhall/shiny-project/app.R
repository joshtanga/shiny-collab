#loading the packages
library(shiny)
library(tidyverse)
library(janitor)
library(bslib)

#cleaning and importing the data
social_media <- read_csv("data/social_media_vs_productivity.csv")|>
    janitor::clean_names()

glimpse(social_media)

colSums(is.na(social_media))

productivity_data <- social_media |>
  select(
    age,
    job_type,
    daily_social_media_time,
    number_of_notifications,
    perceived_productivity_score,
    actual_productivity_score) |>
  filter(
    !is.na(daily_social_media_time),
    !is.na(actual_productivity_score),
    !is.na(perceived_productivity_score)) |>
  mutate(
    social_media_group = case_when(
      daily_social_media_time < 2 ~ "Low",
      daily_social_media_time <= 4 ~ "Medium",
      daily_social_media_time > 4 ~ "High"),
    social_media_group = factor(
      social_media_group,
      levels = c("Low", "Medium", "High")))

glimpse(productivity_data)


# the range of social media usage
daily_range <- range(
  productivity_data$daily_social_media_time,
  na.rm = TRUE
)

# User interface
ui <- page_sidebar(

  title = "Social Media Use & Workplace Productivity",

  # Sidebar inputs
  sidebar = sidebar(

    # slider for daily social media use
    sliderInput(
      "daily_time",
      "Daily Social Media Use (Hours)",
      min = daily_range[1],
      max = daily_range[2],
      value = daily_range
    ),

    # dropdown for job type
    selectInput(
      "job",
      "Select Job Type",
      choices = c("All", sort(unique(productivity_data$job_type))),
      selected = "All"
    ),

    # dropdown for social media group
    selectInput(
      "group",
      "Social Media Usage Group",
      choices = c("All", "Low", "Medium", "High"),
      selected = "All"
    )
  ),

  # app outputs
  h3("Social Media and Productivity"),

  plotOutput("scatter_plot"),

  plotOutput("group_plot"),

  textOutput("summary"),

  tableOutput("data_table")
)

server <- function(input, output, session) {
  
filtered_data <- reactive({

  productivity_data |>
    filter(
      daily_social_media_time >= input$daily_time[1],
      daily_social_media_time <= input$daily_time[2],
      job_type == input$job | input$job == "All",
      social_media_group == input$group | input$group == "All"
    )

})


output$scatter_plot <- renderPlot({
  df <- filtered_data()

  ggplot(
    df,
    aes(
      x = daily_social_media_time,
      y = actual_productivity_score
    )
  ) +
    geom_jitter(
      width = 0.05,
      height = 0,
      alpha = 0.25,
      size = 1
    ) +
    labs(
      title = "Daily Social Media Use vs. Actual Productivity",
      subtitle = "Points are slightly spread horizontally to show overlapping observations",
      x = "Daily Social Media Use (Hours)",
      y = "Actual Productivity Score"
    ) +
    theme_minimal()
})

 

}

shinyApp(ui = ui, server = server)




