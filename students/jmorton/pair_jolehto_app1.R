# --------------------------------------------------------------------------------------------------
# App: jolehto_app4.R
# Author: Joshua Lehto
# Started from: starter-apps/app-basic4.R
# What I changed:
# > tidied up the code
# > changed title and axis labels
# > removed both figs and made plot with one pipeline
# > gave the min, middle, and max of sliderInput a relevant function instead of a set value
# > gave plot_ly a `type` and `mode` to get rid of warnings
# > filter data within a window, rather than everything below a slider value
# What could be better:
# > styling
# --------------------------------------------------------------------------------------------------
# ------------------------------------------------------------
# App:        pair_jolehto_app1.R
# Original author: Josh Lehto  (students/jolehto/jolehto_app4.R)
# Pair-modified by: Jett Morton
# What I changed:
#   - changed dataset to Theoph
#   - changed title 
# ------------------------------------------------------------

# Library
library(tidyverse)
library(plotly)
library(datasets)
library(bslib)
library(shiny)

ui <- page_fluid(
  titlePanel("Time-dependent Concentration of Theophylline given Weight"),
  sidebarLayout(
    # Sidebar Panel
    sidebarPanel(
    sliderInput("Wt",
              "Set weight (Wt)",
              min = min(Theoph$Wt),
              max = max(Theoph$Wt),
              value = min(Theoph$Wt)),
  selectInput("Subject",
              "Choose Subject",
              choices = levels(Theoph$Subject),
              selected = levels(Theoph$Subject)[1])),

    # Show a plot of the generated distribution
    mainPanel(
      # Use plotlyOutput, not plotOutput!
      plotlyOutput("graph"), 
    )
  )
)

server <- function(input, output) {
  
  output$graph <- renderPlotly({

  # filter within the plot_ly call is ok
  plot_ly(filter(Theoph,
                 Wt < input$Wt,
                 Subject == input$Subject), 
          x = ~Time,
          y = ~conc,
          z = ~Wt,
          color = ~Subject)
})
  
  output$table <- renderTable({
  mydata <- filter(Theoph,
                   Wt < input$Wt,
                   Subject == input$Subject) |> 
    arrange(desc(Wt))

  tibble(Subject = mydata$Subject,
         Time = mydata$Time,
         conc = mydata$conc,
         Wt = mydata$Wt)
})
}

# Run the application 
shinyApp(ui = ui, server = server)