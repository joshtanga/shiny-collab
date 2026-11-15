library(tidyverse)
library(janitor)

county_data <- read_csv("data/Poverty2023.csv",
  na = c("", "NA", "N/A"),
  show_col_types = FALSE
) |>
  clean_names() |>
  
  # Change the data from 25 rows per county
  # to one row per county with separate measurement columns
  pivot_wider(
    id_cols = c(fips_code, stabr, area_name),
    names_from = attribute,
    values_from = value
  ) |>
  
  # Clean the new column names created from attribute
  clean_names() |>
  
  # Give the identifier columns shorter names
  rename(
    fips = fips_code,
    state = stabr,
    county = area_name
  ) |>
  
  # Make sure every county FIPS code contains five characters
  mutate(
    #str_pad() adds leading or trailing zeros
    fips = str_pad(
      fips,
      width = 5,
      side = "left",
      pad = "0"
    )
  ) |>
  
  # Keep county records and remove national and state summaries
  filter(
    str_sub(fips, 3, 5) != "000"
  ) |>
  
  # Convert the measurement columns from text to numbers
  mutate(
    across(
      where(is.character) &
        !all_of(c("fips", "state", "county")),
      parse_number
    )
  ) |>
  
  # Keep only the variables needed by the app
  select(
    fips,
    state,
    county,
    poverty_count = povall_2023,
    poverty_rate = pctpovall_2023
  ) |>
  
  # Remove counties missing either value used by the app
  filter(
    !is.na(poverty_count),
    !is.na(poverty_rate)
  )

glimpse(county_data)
