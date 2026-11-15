# app.R

**Author:** Carson Argall

## The question
Where are most meteorites found? What is the biggest meteorite found in that area?

## The data
- **Source:** [Meteorite Landings](https://www.kaggle.com/datasets/nasa/meteorite-landings)
- **One row is:** One unique meteorite
- **Variables I use:** I use the variables: `name`, `recclass`, `mass`, `fall`, `year`, `reclat`, `reclong`, `country`
- **Cleaning:** I filtered so the year had to be between 860 and 2016, because the data page said that any date before or after that was incorrect. I also filtered out some lattitudes and longitudes that I was advised to do because they were inaccurate.

## How to run it
1. Install the packages: `install.packages(c("shiny", "bslib", "tidyverse","dplyr", "sf", "rnaturalearth","rnaturalearthdata", "scales"))`
2. Open `app.R` in Positron and click **Run App**.

## What the app does
- **Inputs:** `map_click` input, allows users to click around different countries to see how many meteorites have been found there, and what the largest meteorite found in that area is. A `select input` for both `class`, and `fall/fell`, `class` because if you were really interested and wanted to see if a specific class has been found in an area you could find that, and `fall/fell` to see if the meteorite was observed falling or if it was just found. A `slider input` to change the range of years so you could see when the meteorites were observed.
- **Outputs:** I use a `renderPlot` output to display the world map showing where most meteorites have fallen, and where less meteorites have fallen. I use a `value_box` output to show the largest meteorite that has been found in the selected area, and what it's mass, class, and year observed are. I use a `tableOutput` to show the total amount of meteorites that have been observed in the area selected, what percentage of the total amount in the world have been found in that area, and total mass and average mass of meteorites in that area.

## One thing I learned
One thing that I discovered using my own app is that Antarctica has the most amount of meteorites that have been found in the world at 69.18% of the total meteorites being found there.(This is because of the contrast between rocks and ice, and lack of other rocks, making it easier to spot them. They also get perserved in the ice). The map also shows dark blue in areas of the world that have dense vegetation.

## Limitations
This data cannot tell us information about meteorites that fell or were found before the year 860, or after the year 2016. It also cannot show us the amount of meteorites that have been recovered from the water.
