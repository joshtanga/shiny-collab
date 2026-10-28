library(plotly)
library(palmerpenguins)
library(shiny)
library(tidyverse)
library(bslib)

ui <- page_fluid(
  titlePanel("Comparing the sexes bill depth using proximity: plotly"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("bill_depth",
                  "Set bill depth",
                  min = 13.1,
                  max = 21.5,
                  value = 15),
      sliderInput("bd_window",
                  "Set bill depth window",
                  min = 0.1,
                  max = 10.1,
                  value = 0.2),
      selectInput("sex",
                  "Choose sex",
                  choices = c("male","female"),
                  selected = "female")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      p("Here we demonstrate how to write text in RShiny. A new p() command starts a new paragraph.", style = "font-family: 'times'; font-size:10pt"),
      strong("The strong() function makes text bold."),
      p('Or embed ', em('emphasized text'), ' inside a paragraph using the em() function.'),
      p('Likewise, make a single word bold by breaking up the p() with commas & use strong() ',strong('like'),' this.'),
      br(),
      p('Display code ', code('ggplot(data = penguins) + geom_point()'), ' inside a paragraph using the code() function.'),
      div("div creates segments of text with a similar style. This division of text is all blue because I passed the argument 'style = color:blue' to div", style = "color:blue"),
      br(),
      p("span does the same thing as div, but it works with",
        span("groups of words", style = "color:blue",
        "that appear inside a paragraph.")),
      p('Links work by using tags()$a for example ', tags$a(href="https://plotly.com/r/", "Link to Plotly for R website"),
      br(),
      p("tags() allows you to use HTML commands directly. For example, to insert an image from the web use",
        code("tags($img(src = 'url, height=100,width=100')")),
      tags$img(src = "https://www.r-project.org/logo/Rlogo.png", height = 100, width = 100)),
    )
  )
)

X <- c(-100:100)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$graph <- renderPlotly({
    #ggplot(penguins,aes(x=bill_length_mm, y = sex)) + geom_point()
    
    fig <- plot_ly(filter(penguins,
                   abs(bill_depth_mm -input$bill_depth) < input$bd_window,
                   sex == input$sex), 
            x = ~body_mass_g,
            y = ~bill_length_mm,
            z = ~flipper_length_mm,
            color = ~species) 
     fig <- fig |> add_markers()
     fig <- fig %>% layout(title = 'Penguins by the Numbers', 
                            scene =
                             list(xaxis = list(title = 'Body Mass'),
                                  yaxis = list(title = 'Bill Length'),
                                  zaxis = list(title = 'Flipper Length'
                                  )))
  })
  
  output$table <- renderTable({
    tibble(x = input$x, y = (input$x)^2)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

