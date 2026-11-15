### Shiny App Project
### Name: Celia Wallace
### DATA 309 - Fall 2026

# Load packages
library(shiny)
library(tidyverse)
library(bslib)
library(janitor)

##### 1) Load and Clean Data #####

mydata <- read_csv("data/student_grade_ses_dataset.csv")

mydata <- mydata |>
  na.omit() |>
  clean_names()

##### 2) User Interface #####

ui <- page_sidebar(

  title = "How Does Family Income Affect Student Performance?",

  sidebar = sidebar(

    sliderInput(
      inputId = "final_grade_pct",
      label = "Minimum Final Grade (%)",
      min = min(mydata$final_grade_pct),
      max = max(mydata$final_grade_pct),
      value = min(mydata$final_grade_pct)
    ),

    sliderInput(
      inputId = "annual_family_income_inr",
      label = "Minimum Household Income (INR)",
      min = min(mydata$annual_family_income_inr),
      max = max(mydata$annual_family_income_inr),
      value = min(mydata$annual_family_income_inr)
    ),

    selectInput(
      inputId = "gender",
      label = "Select Gender",
      choices = c("All", sort(unique(mydata$gender))),
      selected = "All"
    ),

    checkboxInput(
      inputId = "trend",
      label = "Show Regression Line",
      value = TRUE
    )

  ),

  card(
    card_header("Income vs. Final Grade"),

    plotOutput("scatter_plot", height = "450px")
  ),

  layout_columns(

    card(
      card_header("Average Grade"),
      h3(textOutput("average_grade"))
    ),

    card(
      card_header("Filtered Data"),
      tableOutput("data_table")
    )

  )

)

##### 3) Server #####

server <- function(input, output, session) {

  # Shared reactive dataset
  filtered_data <- reactive({

    data <- mydata |>
      select(
        gender,
        annual_family_income_inr,
        final_grade_pct
      ) |>
      filter(
        final_grade_pct >= input$final_grade_pct,
        annual_family_income_inr >= input$annual_family_income_inr
      )

    if (input$gender != "All") {
      data <- data |>
        filter(gender == input$gender)
    }

    data

  })

  # Scatter Plot
  output$scatter_plot <- renderPlot({

    p <- ggplot(
      filtered_data(),
      aes(
        x = annual_family_income_inr,
        y = final_grade_pct
      )
    ) +
      geom_point(
        color = "#2b5c8f",
        size = 2.5,
        alpha = 0.7
      ) +
      labs(
        title = if (input$gender == "All") {
          "Family Income vs. Final Grade (All Students)"
        } else {
          paste("Family Income vs. Final Grade -", input$gender)
        },
        subtitle = "Filtered using the controls in the sidebar",
        x = "Annual Family Income (INR)",
        y = "Final Grade (%)"
      ) +
      theme_minimal()

    if (input$trend) {
      p <- p +
        geom_smooth(
          method = "lm",
          se = FALSE,
          color = "red"
        )
    }

    p

  })

  # Average Grade
  output$average_grade <- renderText({

    paste(
      round(mean(filtered_data()$final_grade_pct), 1),
      "%"
    )

  })

  # Data Table
  output$data_table <- renderTable({

    head(filtered_data(), 10)

  })

}

##### 4) Run App #####

shinyApp(ui = ui, server = server)