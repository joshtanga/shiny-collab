## **How Does Socioeconomic Background Affect Student Grades?**

#### Author: Celia Wallace

#### **What this project shows us:**

This app explores how socioeconomic background may affect students' academic performance. Users can filter the data to compare different groups of students and see how factors such as parental education, gender, study hours, and socioeconomic status relate to exam scores.

#### **Data Source: Student Grade and Socioeconomic Status Dataset (Kaggle)**

One row is: One individual student.

Variables I use: Gender, Socioeconomic Status, Parental Education, Study Hours, Math Score, Reading Score, Writing Score

Cleaning: I imported the dataset using read_csv(), cleaned the variable names, checked the variable types, and removed missing values before creating the app.

#### **How to Run It**

Install the required packages:

install.packages(c("shiny", "bslib", "tidyverse"))

Open app.R in Positron or RStudio.

Click Run App.

**Inputs**

**Gender:** Filters the data by student gender.

**Socioeconomic Status:** Allows users to compare students from different socioeconomic backgrounds.

**Parental Education**: Filters students based on their parents' highest education level.

**Study Hours Slider:** Lets users view students within a selected range of study hours.

These inputs help users explore how different factors are related to academic performance.

### **Outputs**

**Scatter Plot:** Shows the relationship between study hours and average exam score.

**Summary Table:** Displays the filtered data for closer examination.

**Summary Statistics/Value Box:** Shows information such as the average exam score and number of students in the filtered dataset.

These outputs make it easy to compare groups and identify trends in the data.

**One Thing I Learned**

After exploring the data, I found that students who studied more hours generally earned higher average exam scores. I also noticed that students from higher socioeconomic backgrounds tended to have higher average scores, although there was still variation within every group.

**Limitations**

This dataset shows relationships between variables but cannot prove that one factor causes another. Many other factors that affect student performance, such as motivation, teacher quality, or school resources, are not included in the data.