# Analyzing sleep duration within three levels of daily physical activity

**Author:** Caity Bentley

## The purpose of the app
This interactive app explores the relationship between daily sleep duration and daily physical activity. Using the app, you can closely look at how daily sleep duration varies within each of the three levels of daily physical activity with a plot, tables, and summary value boxes. 

## The data
- **Source:** Modern Lifestyle & Sleep Health Metrics (Maria Aqdas 2026)
                https://www.kaggle.com/datasets/mariaaqdas/modern-lifestyle-and-sleep-health-metrics-2026
- **One row is:** One individual from the lifestyle and sleep health metrics dataset
- **Variables I use:** physical_activity_mins, sleep_duration_hours, sleep_quality_score
- **Cleaning and Prep:** 
    - Selected the three columns above
    - Used drop_na() to make sure there were no missing values
        - After using this dataset for Mini Project 2, I had already found that there were no missing values, but I still wanted to double check
    - Created activity_level column with mutate, factor, and case_when

## How to run it
1. Install the packages: `install.packages(c("shiny", "bslib", "tidyverse", "plotly"))`
2. Make sure csv is in the same folder as the app
3. Open `Shiny-Project.R` in Positron and click **Run App**.

## What the app does
- **Inputs:** 
    - selectInput: Lets you select low, medium, or high activity level group to visualize each group independently. 
    - sliderInput: Lets you select the range of sleep duration shown on the plot and zoom into any spot on the y-axis of the graph.
    - checkboxInput: Adds a trendline to the plot, with a selection to show or hide the trendline. 
    - navset_card_tab: Syncs the data table with the activity level selection for the plot.
- **Outputs:** 
    - plotlyOutput: Creates the scatter plot of Physical activity minutes vs. sleep duration (hours)
    - textOutput in value_box: Creates the value boxes that show number of people, average sleep hours, and average sleep quality for the visible portion of the plot.
    - tableOutput: Creates the data table for the first 50 data points of the selected activity level.

## One thing I learned
- While creating the app I learned how to sync the data table with the activity level selection, which is useful because the tables of the other activity levels show up blank if the selection is not synced. I also learned how to add a trendline that can be turned on and off using a checkbox. 

- While exploring the app, I found how useful and informative the value box showing the number of people in the selection is. If you set the sleep duration to the higher end of the range (7.5-9.7) you can see there are very few people who get this much sleep from the low activity level, and more in the medium and high. 

## Limitations
- The app only shows one activity level at a time, so groups cannot be compared side by side.  
- The data is not applicable to populations outside of this dataset. 
- The data table is not representative of the entire sample, it only shows the first 50 values. A full table would have been to large to incorporate into the app. 
