# Social Media Use & Productivity in the Workplace

**Author:** Abby Hall

## The question
How is daily social media use related to the productivty among workers? 

## The data
- **Source:** Social Media vs. Productivty (<link>)
- **One row is:** One worker's data
- **Variables I use:** 
-  job_type
-  daily_social_media_time
-  percived_productivy_score
-  actual_productivity_score
-  social_media_group
- **Cleaning:** 
-  Used janitor:: clean_names()
-  Found the columns with missing data and filtered it out
-  Made 3 social media usage groups based on daily hours and facotored them into low, medium and high

## How to run it
1. Install the packages: `install.packages(c("shiny", "bslib", "tidyverse", "janitor"))`
2. Open `app.R` in Positron and click **Run App**.

## What the app does
- **Inputs:** 
- Daily Social Media Use is shown as a range slider used to select the number of hours spent on social media
- Job Type is shown with a dropdown menu that can filter workers by job type
- Social media group is shown with a dropdown menu that filters betweens the low, medium or high groups.

These inputs fit this question as it shown the diffrent patterns as the productivy chnages between social media usage and productivity


- **Outputs:** 
-  Scatterplot which shows the relationship between daily social media use and actual productivity scores. 
-  Bar graph which shows the average actual producutivy across the three social media groups
-  Summary Table which shows the median of the producutivy score and number of workers in each social media group

These output fit this question as it shows visiually and statsically the answer. 

# One thing I learned:

One thing I leanred from this project is that spending more time on social media does not nessarily mean lower prodicity score. Across all of the social media groups the median productivy was very similar only differning by 0.07 showing that it is pretty flat across the board. Also, I leanred that using shiny to express this data makes it more interactive which shows that it can answer more specific questions with the filtering etc. 

## Limitations
This data set has limitations as other factors can influence producutivy rather than social media. Also this can not be generalized to the public as it is just one sample. The social media groups are also based on hourly cutoffs that i determined changing these may affect the data.

![screenshot of my app](screenshot.png)

