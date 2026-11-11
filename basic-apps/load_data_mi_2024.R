# Michigan 2024 presidential results by county
# click a county to see its results
library(shiny)
library(bslib)
library(tidyverse)
library(jsonlite)
library(scales)
library(sf)

# ---- data ------------------------------------------------------------------
# Helper function to find data file regardless of current working directory
# (e.g., whether running via runApp() inside mi-voting-pop or sourcing from week11)
find_data_file <- function(filename) {
  candidates <- c(
    filename,
    file.path("data", filename),
    file.path("..", filename),
    file.path("..", "data", filename),
    file.path("..", "..", "data", filename),
    file.path("~/g/teaching/dat309/data", filename)
  )
  found <- candidates[file.exists(candidates)]
  if (length(found) == 0) {
    stop("Could not find file: ", filename)
  }
  found[1]
}

json_path <- find_data_file("mi_voting_2024.json")

# read the JSON; flatten = TRUE turns votes$Harris etc. into votes.Harris columns
raw_data <- fromJSON(json_path, flatten = TRUE)

votes <- raw_data$data |>
  as_tibble() |>
  transmute(
    fips = str_remove(jurisdictionTag, "county:"), # "county:26001" -> "26001"
    county = jurisdictionName,
    harris = votes.Harris,
    trump = votes.Trump,
    other = votes.Other,
    total = totalVotes,
    margin_votes = marginVotes,
    margin_pct = marginPct,
    winner = winner
  ) |>
  mutate(
    harris_pct = 100 * harris / total,
    trump_pct = 100 * trump / total,
    other_pct = 100 * other / total
  )

# county shapes: same geometry as app-voting-pop.R (sf object, geometry column "geom")
# join on fips so county-name spelling differences can't break the match
mi_map <- read_rds(find_data_file("mi_v_pop.rds")) |>
  select(fips, geom) |>
  left_join(votes, by = "fips")

# statewide totals, shown before any county is clicked
state <- votes |>
  summarize(
    county = "Michigan (statewide)",
    across(c(harris, trump, other, total), sum)
  ) |>
  mutate(
    harris_pct = 100 * harris / total,
    trump_pct = 100 * trump / total,
    other_pct = 100 * other / total,
    winner = if_else(harris > trump, "Harris", "Trump"),
    margin_votes = abs(harris - trump),
    margin_pct = 100 * margin_votes / total
  )

# party colors (same as app-voting-pop.R)
party_colors <- c(Harris = "#00AEF3", Trump = "#E81B23")
