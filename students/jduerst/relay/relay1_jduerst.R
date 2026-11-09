# ------------------------------------------------------------
# App:        jmorton_app2.R
# Original Author:     Jett Morton
# Relay Author: Janson Duerst
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - changed library to use Theoph data
#   - change slider and select button in ui
#   - changed graph and table in server to use Theoph data
# Relay:
# Added Tabs: navset_card_tab() -- First put everything in cards
# ------------------------------------------------------------


library(plotly)
library(datasets)


# level 5 complexity
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fillable(
  titlePanel("Using Cards and Theoph data to demonstrate using plotly"),
  layout_column_wrap( width = 1/2,

    card(
      sliderInput("Wt",
              "Set weight (Wt)",
              min = min(Theoph$Wt),
              max = max(Theoph$Wt),
              value = min(Theoph$Wt)),),
  card(
  selectInput("Subject",
              "Choose Subject",
              choices = levels(Theoph$Subject),
              selected = levels(Theoph$Subject)[1])),
    
      

  
    navset_card_tab(
  nav_panel("Plot",  plotlyOutput("graph")),
  nav_panel("Table", tableOutput("table"))
))
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

