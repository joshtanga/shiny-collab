# Video Game Publishers Sales

**Author:** Lyle Rhoades

## The question
Which video game publishers have the highest total global sales, and how do their sales compare across different genres, geographic regions, and release years?

## The data
- **Source:** Video Games Sales with Ratings(https://www.kaggle.com/datasets/rush4ratio/video-game-sales-with-ratings)
- **One row is:** A video game released on a specific gaming platform, including its publisher, genre, release year, and sales information.
- **Variables I use:** Name, Platform, Year of Release, Genre, Publisher, NA sales, Eu Sales, Global sales
- **Cleaning:** I used janitor::clean_names() to clean the cloumn names and select() to keep the variable needed for for the project. I checked for missing values, removed rows with incomplete information, and converted the release years into integers. I Also filtered out invalid release years so the year slider would work correctly

## How to run it
1. Install the packages: `install.packages(c("shiny", "bslib", "tidyverse", "janitor"))`
2. Open `app.R` in Positron and click **Run App**.

## What the app does
- **Inputs:** 
PUBLISHER FILTER: Select a specific publisher or view all publishers. Which compares video game companies.
GENRE FILTER: Explore slaes withn different gaming generes, such as action, Shooter, and Sports.
YEAR RANGE SLIDER: Select a rang of release years to see how sales differ across time periods.
- **Outputs:** 
PUBLISHER SALES BAR GRAPH: Displays the top 10 publishers based on total global sales. Bar graph is good for comparing different compaines
GLOBAL SALES BY RELEASE YEAR LINE GRAPH: Shows the total recorded sales of games released in each year. Helps to show trends across the years
REGIONAL SALES TABLE: Displays the top 10 publishers and their total sales in North America, Europe, and globally. This makes it easier to compare sales in different regions
-The app uses a shared reactive() finction so all three outputs automatically update when the user cahnge the filters.

## One thing I learned
One thing I learned from using my own app is that nintendp had the highest total global sales. Also there was a huge jump in gaming sales in 2008 and 2012 which makes sense after i did some other research and so many popular games came out in those years.

## Limitations
A limitation is that this data only goes to the year 2016 so this would not explain the current gaming market. Another limitation is that the data shows estimated sales associated with games released in particular years, rather than the number of copies sold during each calendar year and I only use North America, Europe and gloabl sales which is not a super detailed report of all countries.
