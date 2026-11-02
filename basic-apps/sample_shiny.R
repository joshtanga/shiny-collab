# basic shiny app

library(shiny)
library(tidyverse)
library(bslib)


# description of mtcars variables taken from ?mtcars
mtcars_vars <- tribble(
  ~var   , ~description                               ,
  "mpg"  , "Miles/(US) gallon"                        ,
  "cyl"  , "Number of cylinders"                      ,
  "disp" , "Displacement (cu.in.)"                    ,
  "hp"   , "Gross horsepower"                         ,
  "drat" , "Rear axle ratio"                          ,
  "wt"   , "Weight (1000 lbs)"                        ,
  "qsec" , "1/4 mile time"                            ,
  "vs"   , "Engine (0 = V-shaped, 1 = straight)"      ,
  "am"   , "Transmission (0 = automatic, 1 = manual)" ,
  "gear" , "Number of forward gears"                  ,
  "carb" , "Number of carburetors"
)


ui <- page_fillable(
  layout_sidebar(
    sidebar = sidebar(
      h1("Random MTCARS Explorer"),
      p(
        "Click to randomly select two numeric variables from the mtcars dataset and plot them against each other."
      ),
      actionButton("click_me", "Click Me")
    ),
    card(
      card_header("Numerical Variables in mtcars"),
      p("Randomly selected numerical variables from the mtcars dataset."),
      plotOutput("my_plot")
    ),
    card(
      card_header("Description of Variables"),
      card_body(
        p(
          "The following text describes the two randomly selected variables from the mtcars dataset."
        ),
        textOutput("text_desc")
      )
    )
  )
)

server <- function(input, output, session) {
  # randomly select two numeric variables
  num_vars <- names(mtcars |> select(where(is.numeric)))

  # Use eventReactive so my_data re-samples/updates when input$click_me is clicked
  my_data <- eventReactive(
    input$click_me,
    {
      selected_cols <- sample(num_vars, 2)
      mtcars |>
        select(all_of(selected_cols))
    },
    ignoreNULL = FALSE
  ) # ignoreNULL = FALSE ensures it runs once on app startup

  # Use reactive so desc_1 and desc_2 update whenever my_data() changes
  desc_1 <- reactive({
    filter(mtcars_vars, var == names(my_data())[1]) |>
      pull(description)
  })
  desc_2 <- reactive({
    filter(mtcars_vars, var == names(my_data())[2]) |>
      pull(description)
  })

  output$my_plot <- renderPlot({
    # notice the use of the my_data() syntax to call the reactive function
    df <- my_data()
    # df has 2 columns: names(df)[1] and names(df)[2]
    ggplot(
      df,
      aes(
        x = .data[[names(df)[1]]],
        y = .data[[names(df)[2]]]
      )
    ) +
      geom_point(size = 4) +
      theme_minimal() +
      # the labels are reactive and will update when the user clicks the button
      labs(x = desc_1(), y = desc_2())
  })

  output$text_desc <- renderText({
    # Get the description of the first variable
    paste0(desc_1(), " vs ", desc_2())
  })
}

shinyApp(ui = ui, server = server)
