library(shiny)

ui <- shinyUI(
    fluidPage(
      radioButtons('layout', 'Layout:', 
                   choices=c('Sidebar', 'WellPanel'), inline=TRUE),
      uiOutput('general_ui')
    )
  )

server <- shinyServer(function(input, output) {
    output$general_ui <- renderUI({
      if (input$layout == "Sidebar") {
        sidebarLayout(
          sidebarPanel(
            uiOutput('ui')
          ),
          mainPanel(
            plotOutput('plot')
          )
        )
      } else if (input$layout == "WellPanel") {
        fluidRow(
          column(12, plotOutput('plot')),
          column(12, wellPanel(uiOutput('ui')))
        )
      }
    })
    
    output$ui <- renderUI({
      list(
        checkboxInput('inp1', 'Some stuff'),
        sliderInput('inp2', 'Some more stuff', 0, 10, 5)
      )
    })
    
    output$plot <- renderPlot({ plot(1) })
  })
shinyApp(ui,server)
