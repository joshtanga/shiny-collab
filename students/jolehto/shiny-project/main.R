# ----- Imports --------------------------------------------------

if (!"pacman" %in% rownames(installed.packages())) { # install pacman if it isn't already installed
  install.packages("pacman")
}

pacman::p_load( # load all packages and download/install if needed
  shiny,
  bslib,
  DT,
  tidyverse,
  plotly,
  rnaturalearth,
  sf,
  scales
)

# ----- Data -----------------------------------------------------
# > Map Data
world <- ne_countries(scale = "small", returnclass = "sf") |> 
  select(geometry, iso_a3, name_en) |>
  st_transform(crs = "+proj=natearth") |> # use natural earth projection
  rename(name = name_en)

# > Energy Data
energy_df <- read.csv("shiny-project-jl/data/release_generation_yearly_global.csv") |> 
  select(
    Area,
    ISO.3.code,
    Year,
    Electricity.source,
    Generation..TWh.,
    Share.of.generation....,
    Emissions..MtCO2e.
  ) |>
  janitor::clean_names() |>
  filter(year < 2025 & year >= 2000) |> # data outside of these ranges seems incomplete
  rename(
    iso_a3 = iso_3_code,
    generation_twh = generation_t_wh,
  ) |>
  mutate(
    share_of_generation = case_when( # some data exceeds 100, so just set them as 100
      share_of_generation > 100 ~ 100,
      TRUE ~ share_of_generation
    )
  )

# ----- User Interface --------------------------------------------------
ui <- page_sidebar(

  title = "Global Energy Data",

  sidebar = sidebar(

    sliderInput( # input1
      "year",
      "Year",
      min = min(energy_df$year), 
      max = max(energy_df$year),
      value = 2020,
      step = 1,
      sep = ""
    ),
    radioButtons( # input2
      "source",
      "Electricity Source",
      choices = c("All Sources", "Renewables", "Fossil Fuels"),
      selected = "All Sources"
    ),
    selectInput( # input3
      "category",
      "Variable to Analyze",
      choices = c("Generation (TWh)", "Share of generation (%)", "Emissions (MtCO2e)"),
      selected = "Generation (TWh)"
    )
  ),
  
  navset_card_underline(
    title = "Visualizations: ",

    nav_panel("Map", plotlyOutput("myplot")),
    nav_panel("Table", DTOutput("mytable")),
    nav_panel("Barplot", plotOutput("mybarplot"))

  )
)

 # ----- Server ---------------------------------------------------------
server <- function(input, output, session) {

  # --- real_category ---
  # convert human readable text to proper column name in dataset
  real_category <- function(){
    if (input$category == "Generation (TWh)") {
      real_cat = "generation_twh"
    } else if (input$category == "Emissions (MtCO2e)") {
      real_cat = "emissions_mt_co2e"
    } else if (input$category == "Share of generation (%)") {
      real_cat = "share_of_generation"
    }
    return(real_cat)
  }

  # --- real_source ---
  # convert human readable text to proper variable name in dataset
  real_source <- function(){
    if (input$source == "All Sources") {
      real_src = "Total generation"
    } else if (input$source == "Renewables") {
      real_src = "Renewables"
    } else if (input$source == "Fossil Fuels") {
      real_src = "Fossil"
    }
    return(real_src)
  }

  # --- current ---
  current <- reactive({
    category = real_category()
    source = real_source()

    # > Data that changes with Input
    global_energy_df <- energy_df |>
      filter(
        year == input$year,
        electricity_source %in% source
      )

    global_energy_df <- world |> # pipe world into left join first to maintain `sf` data type, instead of `data.frame`
      left_join(global_energy_df, by = "iso_a3") |>
      arrange(desc(.data[[category]]))

  })

  # --- myplot ---
  output$myplot <- renderPlotly({
    category = real_category()

    # > World Map
    p <- current() |>
      # Data
      mutate(text = paste(
        name, "\n",
        input$category, ": ", .data[[category]],
        sep = ""
      )) |>
      # Plot
      ggplot(aes(text=text)) +
      geom_sf(aes(fill = .data[[category]]), color = "black") +
      # Labels
      scale_fill_viridis_c(na.value = "grey35", labels = label_comma()) +
      labs(
        title = paste0(input$source, ", ",input$year),
        fill = input$category
      ) +
      # Theme
      theme_minimal() + # use minimal as a base, but add some stuff
      theme(
          text = element_text(family = "serif"),
          plot.title = element_text(face = "bold"),
          plot.subtitle = element_text(face = "italic")
      )

    # Give created plot to plotly for interactivity
    ggplotly(p, tooltip = "text") |> # tooltip
    style(hoveron = "fills") |> # give tooltip when hovering over a country(fill)
    layout(dragmode = "pan") |>
    config(scrollZoom = TRUE)

  })

  # --- table ---
  output$mytable <- renderDT({
    category = real_category()

    current() |>
      as_tibble() |> # convert from sf to tibble to remove geom data
      select(name, any_of(category)) |>
      rename(
        Country = name,
        !!input$category := any_of(category),
      ) |>
      datatable()
  })

  # --- barplot ---
  output$mybarplot <- renderPlot({
    category = real_category()
    source = real_source()

    if (source == "Total generation") source = c("Fossil", "Renewables")

    energy_df |>
      # Data
      filter(
        area == "World",
        electricity_source %in% source,
        year <= input$year
      ) |>
      # Plot
      ggplot(aes(x=as.factor(year), y=.data[[category]], fill = electricity_source)) +
      geom_col(position = "stack") +
      # Labels
      scale_fill_manual(limits = c("Fossil", "Renewables"), values = c("red3", "seagreen3")) +
      labs(
        title = "Global Energy",
        subtitle = paste0(input$source, ", ", input$year),
        fill = "Electricity Source",
        x = "Year",
        y = paste("Total", input$category)
      ) +
      # Theme
      theme_minimal() +
      theme(
        text = element_text(family = "serif"),
        plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(face = "italic")
      )
  })
}

shinyApp(ui, server)