#Where are most meteorites found? Has that changed over time?
library(tidyverse)
library(shiny)
library(bslib)
library(dplyr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(scales)

meteor <- read_csv("data/meteorite-landings.csv") |>
  janitor::clean_names()
#check missing values from data
meteor |> summarize(
    across(everything(), ~ sum(is.na(.x)))
)
#clean the values that needed cleaning
meteorClean <- meteor |>
  filter(
    (year >= 860 & year <= 2016),
    (reclong <= 180 & reclong >= -180 & (reclat!=0 | reclong!=0)),
    mass != "NA") |>
  rename(meteorite = name)
#check to make sure there are no more missing values
meteorClean |> summarize(
    across(everything(), ~ sum(is.na(.x)))
)

#installed rnaturalearthdata, dataset
#Get dataset containing geographic boundries
countries <- ne_countries(
  scale = "medium",
  returnclass = "sf"
)
#make data to use lattitude and longitude using a coordinate system.
meteorSF <- meteorClean |>
  st_as_sf(
    coords = c("reclong", "reclat"),
    crs = 4326
  )

#assigns country to meteorites
meteorSF <- st_join(
  meteorSF,
  countries["name"],
  join = st_within
) |>
  rename(country = name)
#gets how many meteorites observed in each country
meteorCount <- meteorSF |>
  st_drop_geometry() |>
  group_by(country) |>
  summarize(
    meteorite_count = n()
  )

countryMap <- countries |>
  left_join(
    meteorCount,
    by = c("name" = "country")
  )

ui <- page_fillable(
  tags$style(HTML("
  #bigName, #bigMass, #bigClass, #bigYear {
    font-size: 14px;
  }
  ")),

  titlePanel(h1(
    "Meteorite Landings",
    align = "center"
  )),

  layout_columns(
    col_widths = c(8, 4),

    card(
      card_header("Click a country"),
      plotOutput("map", click = "map_click", height = "750px")
    ),

    card(
      card(
        card_header("Filter Meteorites"),

        sliderInput(
          "year",
          "Year Range",
          min = 860,
          max = 2016,
          value = c(860, 2016)
        ),

        selectInput(
          "class",
          "Meteorite Classification",
          choices = c("All", sort(unique(meteorSF$recclass))),
          selected = "All"
        ),

        selectInput(
          "fall",
          "Meteorite Type",
          choices = c("All", "Fell(Meteorite fall observed)", "Found(Meteorite fall not observed)"),
          selected = "All"
        )
      ),

      card(
        card_header(textOutput("countryName")),

        value_box(
          title = "Biggest Meteorite",
          value = tagList(
            textOutput("bigName"),
            textOutput("bigMass"),
            textOutput("bigClass"),
            textOutput("bigYear")
          )
        )
      )
      
    ),
    tableOutput("stats_table")
  )
)
#---------------------------------- server ------------------------------------
server <- function(input, output) {
# reactiveVal so the selection survives the plot re-draw
  #starts with no country clicked, then updates when a country is clicked
  selected <- reactiveVal(NULL)

  #used to turn click into geographic point using longitude and lattitude, and coordinate system
  observeEvent(input$map_click, {
    pt <- st_sfc(
      st_point(c(input$map_click$x, input$map_click$y)),
      crs = st_crs(countryMap)
    )
    # st_intersects() finds the intersection between the map and the click
    hit <- countryMap[st_intersects(countryMap, pt, sparse = FALSE)[, 1], ]
    # clicking off the map (or on a county with no data) resets to worldwide
    selected(if (nrow(hit) == 1 && !is.na(hit$meteorite_count)) hit else NULL)
  })

  #create a filter to be able to use the inputs on the shiny page
  meteorFilter <- reactive({
    meteorSF |>
      filter(
        input$class == "All" | recclass == input$class,
        year >= input$year[1], year <= input$year[2],
        input$fall =="All" | fall == input$fall
      )
  })

  # current() returns the selected country, or worldwide if none is selected
  #gets the meteorites that match input selected
  #worldTotal gets assigned the number of all meteorites
  #if no country is selected, sets countryName to "Worldwide" to display
  #if a country is selected, filter so that only meteorites belonging to the country selected are used
  #if there are no values for the selected country it stays as worldwide
  #Then get the country and store it in countryName to display
  #Find the largest meteorite in selected, and get data that is to be displayed
  current <- reactive({
  cur <- meteorFilter() |>
    st_drop_geometry()

  worldTotal <- nrow(cur)

  if (is.null(selected())) {
    countryName <- "Worldwide"
  } else {
    
    cur <- cur |>
      filter(country == selected()$name)

    if (nrow(cur) == 0) {
      return(NULL)
    }
    countryName <- first(cur$country)
  }
  largest <- cur |>
    slice_max(mass, n = 1)

  cur |>
    summarize(
      country = countryName,
      meteoriteTotal = n(),
      totalMass = sum(mass, na.rm = TRUE),
      meanMass = mean(mass, na.rm = TRUE),
      largestMass = largest$mass,
      largestClass = largest$recclass,
      largestYear = largest$year,
      largestName = largest$meteorite,
      percentTotal = (n() / worldTotal) * 100
    )
  })

  #use renderPlot to make a world map and have it create a border around the selected country
  output$map <- renderPlot({
    p <- ggplot(countryMap) +
      geom_sf(
        aes(fill = meteorite_count),
        color = "white",
        linewidth = .1) +
      scale_fill_viridis_c(trans = "log", name = "Meteorite Count",labels = label_number(accuracy = 1, big.mark = ",")) +
      theme_minimal()

    if (!is.null(selected())) {
      p <- p +
        geom_sf(data = selected(), fill = NA, color = "black", linewidth = 1)
    }
    p
  })

  #use renderText to get values that I want to display on shiny app
  output$countryName <- renderText(current()$country)

  output$bigName <- renderText({
    paste("Name:", current()$largestName)
  })

  output$bigMass <- renderText({
    paste("Mass:", format(current()$largestMass, big.mark = ",", scientific = FALSE), "g")
  })

  output$bigClass <- renderText({
    paste("Class:", current()$largestClass)
  })

  output$bigYear <- renderText({
    paste("Year Found/Fell:", current()$largestYear)
  })

  #Make a table to show some interesting things about the data selected
  output$stats_table <- renderTable({
  cur <- current()
  tibble(
    `Total Meteorites` = cur$meteoriteTotal,
    `Total Mass(g)` = cur$totalMass,
    `Average Mass(g)` = cur$meanMass,
    `Percent of total Meteorites` = paste0(round(cur$percentTotal,2), "%")
  )
})

}

shinyApp(ui, server)


