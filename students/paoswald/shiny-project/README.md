# <TemperatureAnomalyComparisons>

**Author:** <Patton Oswald>

## The question
<This app allows people to compare temperature anomalies within the last century. They are able to select up to two countries and the time range that they would like to explore, allowing them to see how these anomalise have changed over time.>

## The data
- **Source:** [<Annual temperature anomalies 2025>](<https://ourworldindata.org/grapher/annual-temperature-anomalies>)
- **One row is:** <Is one country's temperature anomaly for the year.>
- **Variables I use:** <country, year, temperature_anomaly>
- **Cleaning:** <I used clean_names() to make the column names uniform. I used rename() to turn countey to country. I also used glimpse to check my data, and I used colSums to look for N/A values.>

## How to run it
1. Install the packages: `install.packages(c("shiny", "bslib", "tidyverse", "janitor"))`
2. Open `app.R` in Positron and click **Run App**.

## What the app does
- **Inputs:** <each There are two different country drop downs allowing you to select different countries to compare temperature anomalies. There is also a year slider allowing you to pick the time period that you woul dlike to investigate.>
- **Outputs:** <I have a line graph that shows the temperature anomaly by year for each country. There is a summary statistics table that shows both countries min, max, and mean temperature anomalies. There is also a data preview that shows the first 10 rows of the selected dataset.>

## One thing I learned
<Even though there are global trends of increasing temperature anoamly, there can still be significant variation eyar by year in seperate countries temperature anomalies.>

## Limitations
<This app can only compare two countries at a time and it only shows temperature anomalies from an unknown reference year, instead of just normal temperatures in Celcius. >

![screenshot of my app](Screenshot%202026-11-10%20194509.png)