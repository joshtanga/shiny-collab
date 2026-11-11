#loading the packages

library(tidyverse)
library(janitor)
library(bslib)

#cleaning and importing the data
social_media <- read_csv("data/social_media_vs_productivity.csv")|>
    janitor::clean_names()

glimpse(social_media)

colSums(is.na(social_media))

productivity_data <- social_media |>
  select(
    age,
    job_type,
    daily_social_media_time,
    number_of_notifications,
    perceived_productivity_score,
    actual_productivity_score) |>
  filter(
    !is.na(daily_social_media_time),
    !is.na(actual_productivity_score),
    !is.na(perceived_productivity_score)) |>
  mutate(
    social_media_group = case_when(
      daily_social_media_time < 2 ~ "Low",
      daily_social_media_time <= 4 ~ "Medium",
      daily_social_media_time > 4 ~ "High"),
    social_media_group = factor(
      social_media_group,
      levels = c("Low", "Medium", "High")))

glimpse(productivity_data)
