# use cards and navset to give multiple tabs
library(plotly)
library(palmerpenguins)
library(bslib)
library(shiny)
library(tidyverse)

ui <- page_fillable(

  titlePanel("Demonstration of using cards() to control layout in RShiny"),

  layout_column_wrap(
    width = 1/2, # so we have two columns
  
    # change titlePanel to card_header and put it in a card()
    # first card with sliderInput
    card(
      card_header("Filtering bill depth with slider with plotly"),
      # kill sidebarLayou & sidebarPanel
      sliderInput("bill_depth",
                  "Set bill depth",
                  min = 13.1,
                  max = 21.5,
                  value = 15),
      sliderInput("bd_window",
                  "Set bill depth window",
                  min = 0.1,
                  max = 10.1,
                  value = 0.2)
      ), # 1st card
    # second card with selectInput
    card(
      selectInput("sex",
                  "Choose sex",
                  choices = c("male","female"),
                  selected = "female")
      ), # 2nd card
    

    # third card with text
    card(
      card_body(
        p("Here, we compare penguins by sex."),
        p("We also demonstrate how to write text in RShiny. A new p() command starts a new paragraph.", style = "font-family: 'times'; font-si16pt"),
        strong("The strong() function makes text bold."),
        em("em() creates italicized (i.e, emphasized) text."),
        br(),
        code("code displays your text similar to computer code"),
        div("div creates segments of text with a similar style. This division of text is all blue because I passed the argument 'style = color:blue' to div", style = "color:blue"),
        br(),
        p("span does the same thing as div, but it works with",
          span("groups of words", style = "color:blue",
               "that appear inside a paragraph.")),
        p(str_c("For more: ",r"(https://plotly-r.com/)")),
        br()
        ) # card_body 
    ), # third card
                     

    # fourth card with plotlyOutput
    card(plotlyOutput("graph")),
  ) # layout_column_wrap
) #page_fillable
  


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
} 

# Run the application 
shinyApp(ui = ui, server = server)

