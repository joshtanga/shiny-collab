# this script
#
# 1. create the 2024_US_County_Level_Presidential_Results.csv file,
# 2. creates the edf data frame,
#    which is used in the table_app.R script, and button_app.R
# 3. creates the plots used in the button_app.R script
#    called plot1 and plot2

library(tidyverse)
# expecting the app to be run from the shiny-collab/starter-code directory,
# so the data file up one directory in the data subdirectory
edf <- read_csv("../data/2024_US_County_Level_Presidential_Results.csv")

edf <- edf |>
  mutate(
    winner = ifelse(votes_gop > votes_dem, "Trump", "Harris"),
  )


df <- edf |>
  transmute(
    contribution_blue = per_dem * pop,
    contribution_red = per_gop * pop
  )

df <- df |>
  summarize(
    Harris = sum(contribution_blue, na.rm = TRUE),
    Trump = sum(contribution_red, na.rm = TRUE)
  ) |>
  pivot_longer(
    cols = everything(),
    names_to = "winner",
    values_to = "votes"
  )


plot1 <- edf |>
  ggplot(aes(x = winner, fill = winner)) +
  geom_bar(position = 'stack') +
  scale_fill_manual(
    values = c("Trump" = "#cb181d", "Harris" = "#2171b5"),
    labels = c("Trump" = "Republican", "Harris" = "Democrat")
  ) +
  theme_minimal() +
  labs(title = "2024 Election Results by County", x = "Winner", y = "Counties")


plot2 <- df |>
  ggplot(aes(x = winner, y = votes, fill = winner)) +
  geom_col() +
  scale_fill_manual(
    values = c("Trump" = "#cb181d", "Harris" = "#2171b5"),
    labels = c("Trump" = "Republican", "Harris" = "Democrat")
  ) +
  theme_minimal() +
  labs(
    title = "2024 Election Results by County",
    x = "Winner",
    y = "Popular Vote"
  )
