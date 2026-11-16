### Shiny App Project 
##### Name: Celia Wallace 11/9/2026

library(shiny)
library(tidyverse)
library(bslib)


# Install the package if you haven't already
install.packages("kagglehub")

library(kagglehub)

# Download latest version
path <- dataset_download("chaitanyajamble/grade-prediction-based-on-socioeconomic-factors")

cat("Path to dataset files:", path, "\n")
