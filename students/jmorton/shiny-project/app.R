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

# User interface
ui <- page_fillable(
  titlePanel("Stroke Prediction App"),

   layout_columns(
    col_widths = c(6, 6),
    h4("Patient Information"),

    # Inputs for patient info
    selectInput(
      "gender",
      "Gender",
      choices = levels(stroke$gender)),


    selectInput(
      "hypertension",
      "Hypertension?",
      choices = c("No" = "0", "Yes" = "1")),

    selectInput(
      "heart_disease",
      "Heart Disease?",
      choices = c("No" = "0", "Yes" = "1")),

    numericInput(
      "glucose",
      "Average Glucose Level",
      value = 100,
      min = 1,
      max = 300),

    numericInput(
      "bmi",
      "BMI",
      value = 25,
      min = 10,
      max = 100),

    selectInput(
      "smoking_status",
      "Smoking Status",
      choices = levels(stroke$smoking_status)),

   sliderInput(
      "age",
      "Age",
      min = 1,
      max = 100,
      value = 50)),

  # Output for stroke prediction
  h4("Predicted Stroke Probability"),

  uiOutput("probability_box"),

  p("This prediction is based on patterns in the
    dataset and is not a medical diagnosis."))

# Server
server <- function(input, output, session) {

# Stroke probability output reacts to patient info input
  stroke_probability <- reactive({

    # Creates a data frame containing patient's new data
    patient <- data.frame(
      gender = factor(
        input$gender,
        levels = levels(stroke$gender)),

      age = input$age,
      hypertension = factor(
        input$hypertension,
        levels = levels(stroke$hypertension)), 

      heart_disease = factor(
        input$heart_disease,
        levels = levels(stroke$heart_disease)),

      avg_glucose_level = input$glucose,
      bmi = input$bmi,
      smoking_status = factor(
        input$smoking_status,
        levels = levels(stroke$smoking_status)))

    # Uses model to make a prediction of the stroke probability based on patients new data frame
    predict(
      stroke_model,
      newdata = patient,
      type = "response")})

  # Outputs a box containing stroke prediction as a percent
  output$probability_box <- renderUI({

    probability <- stroke_probability() * 100

    value_box(
      title = "Estimated Stroke Probability",
      value = paste0(round(probability, 2), "%"),
      theme = "primary")})}

# Run the application
shinyApp(ui = ui, server = server)
