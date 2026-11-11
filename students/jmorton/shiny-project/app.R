# Install/load packages
install.packages(c("shiny", "bslib", "tidyverse", "janitor"))
library(bslib)
library(shiny)
library(tidyverse)
library(janitor)

# Import and clean the data
stroke <- readr::read_csv(
  "C:shiny-collab/students/jmorton/shiny-project/data/healthcare-dataset-stroke-data.csv") |>
  janitor::clean_names()

glimpse(stroke)

# Covert variable types
# hypertension: 0 = No, 1 = Yes
# heart_disease: 0 = No, 1 = Yes
# stroke: 0 = No, 1 = Yes
stroke <- stroke |>
  mutate(
    bmi = as.numeric(bmi),
    gender = as.factor(gender),
    smoking_status = as.factor(smoking_status),
    stroke = as.factor(stroke), 
    hypertension = as.factor(hypertension),
    heart_disease = as.factor(heart_disease))

# view missing data
missing <- stroke |>
  summarize(across(everything(),
      ~ sum(is.na(.x)))) |>
  pivot_longer(
    cols = everything(),
    names_to = "Variable",
    values_to = "N/A_count") 

missing

# Remove 201 rows with missing bmi data 
stroke <- stroke |>
  tidyr::drop_na() 

# confirm clean up of N/A
missing <- stroke |>
  summarize(across(everything(),
      ~ sum(is.na(.x)))) |>
  pivot_longer(
    cols = everything(),
    names_to = "Variable",
    values_to = "N/A_count") 

missing

glimpse(stroke)

# Use cleaned dataset to build a binomial logistic regression model to predict an outcome that has two possible categories.
# For example:
# 0 = No stroke
# 1 = Stroke
stroke_model <- glm(
  stroke ~ gender + age + hypertension +
    heart_disease + avg_glucose_level +
    bmi + smoking_status,
  data = stroke,
  family = binomial)


#
ui <- page_fillable(
  titlePanel("Time-dependent Theoph Concentration"),

  # Top row: two shorter cards
  layout_columns(
    col_widths = c(6, 6),

    card(
  height = "150px",
  sliderTextInput(
    inputId = "Subject",
    label = "Choose Subject",
    choices = as.character(unique(Theoph$Subject)),
    selected = "1")),

    card(
      height = "150px",
      card_body(
        p("Theoph")
      )
    )
  ),

  # Bottom row: full-width, taller graph
  card(
    height = "576px",
    width = "100%",
    card_body(
      plotlyOutput(
        "graph",
        width = "100%",
        height = "500px")))
      )
  
# 
server <- function(input, output) {
  output$graph <- renderPlotly({   
    fig <- plot_ly(
      filter(Theoph,
      Subject == input$Subject), 
       x = ~Time,
       y = ~conc,
       color = ~Subject)
    fig <- fig |> add_markers()
    fig <- fig |> add_lines()
    fig <- fig |> layout(title = 'Time-dependent Theoph Concentration', 
    xaxis = list(title = 'Time (hr)'),
    yaxis = list(title = 'Concentration'))
  })} 

# 
shinyApp(ui = ui, server = server)
