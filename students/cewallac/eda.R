# paste your import code in: 

library(shiny)
library(tidyverse)
library(bslib)
##### 1) Load and Clean Data: 

mydata <- read_csv("C:\\Users\\cewallac\\Desktop\\DATA309\\shiny-collab\\students\\cewallac\\shiny_project\\data\\student_grade_ses_dataset.csv")
names(mydata) <- make.names(names(mydata), unique=TRUE)

mydata <- janitor::clean_names(mydata)
glimpse(mydata)

##### 2) User Interface (UI): 



# make plot 1 
# what correlates with grades? 
# use plots, use filtering & grouping to make a cool plot 


library(ggplot2)
library(scales)

mydata |> 
  select(annual_family_income_inr, final_grade_pct) |> 
  ggplot(aes(x = annual_family_income_inr, y = final_grade_pct)) +
  geom_point(color = "#2b5c8f", alpha = 0.7, size = 2.5) +
  geom_smooth(method = "lm", color = "#d95f02", se = FALSE, linetype = "dashed") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(limits = c(0, 100)) +
  labs(
    title = "Relationship Between Family Income and Final Grade",
    subtitle = "Student performance measured against annual family income",
    x = "Annual Family Income (INR)",
    y = "Final Grade (%)",
    caption = "Source: Kaggle"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray30"),
    panel.grid.minor = element_blank()
  )



library(dplyr)
library(knitr)

mydata |> 
  select(
    `Annual Family Income (INR)` = annual_family_income_inr,
    `Final Grade (%)` = final_grade_pct
  ) |> 
  head(10) |> 
  kable(caption = "Sample of Student Income and Grade Data")

library(shiny)
library(ggplot2)
library(dplyr)

ui <- fluidPage(
  titlePanel("Income vs. Grade Explorer"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = "bins",
        label = "Filter by Min Final Grade (%):",
        min = 0,
        max = 100,
        value = 0
      )
    ),
    mainPanel(
      plotOutput("scatter_plot"),
      hr(),
      tableOutput("data_table")
    )
  )
)

server <- function(input, output, session) {
  
  # Filter data dynamically
  filtered_data <- reactive({
    mydata |> 
      select(annual_family_income_inr, final_grade_pct) |> 
      filter(final_grade_pct >= input$bins)
  })
  
  # Render Plot
  output$scatter_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = annual_family_income_inr, y = final_grade_pct)) +
      geom_point(color = "#2b5c8f", size = 2.5, alpha = 0.7) +
      theme_minimal() +
      labs(
        x = "Annual Family Income (INR)",
        y = "Final Grade (%)",
        title = "Family Income vs. Final Grade"
      )
  })
  
  # Render Table
  output$data_table <- renderTable({
    head(filtered_data(), 10)
  })
}

shinyApp(ui = ui, server = server)