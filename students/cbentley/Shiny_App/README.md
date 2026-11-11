# Analyzing sleep duration within three levels of daily physical activity

**Author:** Caity Bentley

## The question
This app uses the same dataset I analyzed in Mini Project 2, and I analyze how the daily sleep duration varies within each of the three levels of daily physical activity. 

## The data
- **Source:** Modern Lifestyle & Sleep Health Metrics (Maria Aqdas 2026)
                https://www.kaggle.com/datasets/mariaaqdas/modern-lifestyle-and-sleep-health-metrics-2026
- **One row is:** One individual from the lifestyle and sleep health metrics dataset
- **Variables I use:** physical_activity_mins, sleep_duration_hours, sleep_quality_score, 
                        activity_level (created from physical_activity_mins)
- **Cleaning:** I had done any cleaning needed for mini project 2, and I found that the dataset was already clean, no na values, and no rows needed to be dropped. I still used drop_na() to double check no na values were present in the dataset. 

## How to run it
1. Install the packages: `install.packages(c("shiny", "bslib", "tidyverse", "plotly"))`
2. Open `Shiny-Project.R` in Positron and click **Run App**.

## What the app does
- **Inputs:** <each input, and why it fits this data>
- **Outputs:** <each output, and why it fits this question>

## One thing I learned
<Something you discovered by using your own app.>

## Limitations
<What the data or the app can't tell you.>

![screenshot of my app](screenshot.png)