# Population and density affects on US election

**Author:** Tate Gordon

Explore how county winners in the 2024 presidential election vary across population and population-density ranges.

## How to run

Install these packages once in R:

```r
install.packages(c("shiny", "bslib", "tidyverse", "scales", "sf", "usmap"))
```

Keep app.R and the data folder together. The CSV is included and read with a relative path; no personal computer paths or separate data downloads are needed. County boundaries come from the usmap package.

## Data and controls

The CSV is the county election data from 2024. Each row describes a county or county-equivalent election reporting area. The app uses county codes and names, state names, Democratic and Republican vote counts, population, and population density (people per square mile).

County codes are read as text to preserve leading zeros. The app checks for duplicate codes, joins records to county boundaries, identifies the winner, and flags missing or invalid population/density values before the server runs.

The sidebar has population and density range sliders, number boxes with **Apply typed range** buttons, and a reset button. A county must pass both filters to keep its winner color. Counties outside the ranges turn gray. Click a county to see its name; the table counts red, blue, and outside-range counties.

Maps show where counties are, sliders fit numeric ranges, and the table makes county counts easier to compare than geographic area alone.

## One thing I learned

The east cost tends to have a much higher population density than those compared to the west coast.  The size of the counties definitly matter too as in the east county sizes are generally smaller.

## Limitations

The map covers the lower 48 United States, excluding Alaska, Hawaii, and territories. County counts are not vote totals; residents are not the same as voters. Geographic patterns show relationships, not proof that population causes voting choices. Missing records and ties have map colors but are not included as rows in the count table.


