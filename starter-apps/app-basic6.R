library(plotly)
library(palmerpenguins)



# level 4 complexity
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Comparing the sexes bill depth using proximity: plotly"),
  sidebarLayout(
    sidebarPanel(
      p('Make Selections to filter the data shown in the plot', style='font-size:8pt'),
      sliderInput("bill_depth",
                  "Set bill depth",
                  min = 13.1,
                  max = 21.5,
                  value = c(0,15)), # a range slider
      selectInput("sex",
                  "Choose sex",
                  choices = c("male","female"),
                  selected = "female")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      # add some text 
      p("This page has: One Range Slider, One Select,  No Table, One Plotly Graph, and a Text Description", style='font-size:10pt'),
      plotlyOutput("graph"),
      h4("Selected Range:"),
      verbatimTextOutput("selected_range"),
      h4("Selected One:"),
      verbatimTextOutput("selected_min")
    )
  )
)


server <- function(input, output) {

    # show the range selected
   output$selected_range <- renderPrint({
        # input$range_selector will be a numeric vector of length 2
        input$bill_depth
    })

    # show just the minimum value selected
   output$selected_min <- renderPrint({
        # input$range_selector will be a numeric vector of length 2
        input$bill_depth[1]
    })

    # create the plotly graph
  output$graph <- renderPlotly({
       plot_ly(filter(penguins,
              bill_depth_mm > input$bill_depth[1], 
              bill_depth_mm <= input$bill_depth[2],
              sex == input$sex), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species) |> layout(scene =
                             list(xaxis = list(title = 'Body Mass'),
                                  yaxis = list(title = 'Bill Length'),
                                  zaxis = list(title = 'Flipper Length')))
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

