# ------------------------------------------------------------
# App:        jmorton_app2.R
# Author:     Jett Morton
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - changed library to use Theoph data
#   - change slider and select button in ui
#   - 
# ------------------------------------------------------------


library(plotly)
library(palmerpenguins)


# level 5 complexity
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Filtering bill depth with slider with plotly"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("Wt",
              "Set weight (Wt)",
              min = min(Theoph$Wt),
              max = max(Theoph$Wt),
              value = min(Theoph$Wt)),
  selectInput("Subject",
              "Choose Subject",
              choices = levels(Theoph$Subject),
              selected = levels(Theoph$Subject)[1])
),
    
    mainPanel(
      plotlyOutput("graph"),
      tableOutput("table")
    )
  )
)


server <- function(input, output) {
  
  output$graph <- renderPlotly({
    
    # filter within the plot_ly call is ok
    plot_ly(filter(penguins,
                   bill_depth_mm < input$bill_depth,
                   sex == input$sex), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species) 
    # fig <- fig %>% layout(scene =
    #                         list(xaxis = list(title = 'Body Mass'),
    #                              yaxis = list(title = 'Bill Length'),
    #                              zaxis = list(title = 'Flipper Length')))
  })
  
  output$table <- renderTable({
    mydata <- filter(penguins,bill_depth_mm < input$bill_depth,sex == input$sex) |> arrange(desc(body_mass_g))
    tibble(body_mass = mydata$body_mass_g, bill_length = mydata$bill_length_mm, flipper_length = mydata$flipper_length_mm, species = mydata$species)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

