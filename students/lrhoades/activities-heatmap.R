# activities-heatmap.R
# Read every student's students/<username>/activities.csv and draw a heatmap:
# one row per student, one column per activity, each cell the percent of
# their week spent on that activity.
#
# Run it from the shiny-collab folder (or from this folder).
# git pull first to get everyone's latest files.

library(tidyverse)

# ---- 1. find the files ---------------------------------------------------------
# The script needs two things: the students/ folder and the template.
# R looks for files relative to its working directory (getwd()), which depends
# on how you opened the project, so we try the likely places.
candidates <- c(".", "..", "shiny-collab")
root <- candidates[dir.exists(file.path(candidates, "students"))][1]
if (is.na(root)) {
  stop(
    "Can't find the students/ folder from ", getwd(), ".\n",
    "Open shiny-collab.Rproj, or run setwd() to your shiny-collab folder."
  )
}
students_dir <- file.path(root, "students")
template <- file.path(root, "activities-heatmap", "activities-template.csv")

# every file named exactly activities.csv, in any student's folder
files <- list.files(
  students_dir,
  # the ^ means the string starts with and the $ means ends with that name, so we don't pick up any other files
  pattern = "^activities\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)
if (length(files) == 0) {
  stop("No students/<username>/activities.csv files yet. Did you git pull?")
}
files # which students have submitted?

# ---- 2. read them all into one table ----------------------------------------------
# read_csv() can read many files at once and stack them.
# id = "file" adds a column saying which file each row came from.
# col_types = "cd" means the first column is character and the second is double.
activities <- read_csv(files, id = "file", col_types = "cd") |>
  mutate(
    # "students/jduerst/activities.csv" -> "jduerst"
    student = basename(dirname(file)),
    # tidy up typos like " Sleep " -> "sleep"
    activity = str_to_lower(str_trim(activity))
  ) |>
  select(student, activity, percent)

# ---- 3. check the data -----------------------------------------------------------
# the activity names everyone is supposed to use, in the template's order
activity_order <- read_csv(template, col_types = "cd")$activity

# rows with an activity name that isn't in the template; these get dropped,
# so tell that student to fix their file
activities |> filter(!activity %in% activity_order)

# keep only the template's activities, and treat a blank percent as 0
activities <- activities |>
  filter(activity %in% activity_order) |>
  # if someone deleted a row, add it back with 0 so every cell has a tile
  complete(student, activity = activity_order, fill = list(percent = 0)) |>
  mutate(percent = replace_na(percent, 0))

# each student's total (should be 100)
totals <- activities |>
  group_by(student) |>
  summarize(total = sum(percent))
totals |> filter(total != 100)

# ---- 4. prepare for plotting ------------------------------------------------------
# rescale each row to add to 100%, in case someone's numbers don't
activities <- activities |>
  group_by(student) |>
  mutate(share = percent / sum(percent)) |>
  ungroup() |>
  filter(!is.na(share)) # drop anyone whose file is still all blank

if (nrow(activities) == 0) {
  stop("Every activities.csv is still blank. Fill in at least one, then run this again.")
}

# order: activities as in the template; students alphabetically from the top
# (ggplot draws the first level at the BOTTOM, so we reverse the order)
student_order <- sort(unique(activities$student), decreasing = TRUE)

activities <- activities |>
  mutate(
    activity = factor(activity, levels = activity_order),
    student = factor(student, levels = student_order)
  )

# the label printed to the right of each row
totals <- totals |>
  filter(student %in% student_order) |>
  mutate(
    student = factor(student, levels = student_order),
    label = if_else(total == 100, "", str_c("entered ", total, "%, rescaled"))
  )

# ---- 5. the heatmap -------------------------------------------------------------
n_activities <- length(activity_order)

heatmap <- ggplot(activities, aes(x = activity, y = student)) +
  # one colored tile per cell; white borders separate the tiles
  geom_tile(aes(fill = share), color = "white", linewidth = 1.5) +
  # the percentage in each tile; white text on dark tiles, dark text on light ones
  geom_text(
    aes(
      label = scales::percent(share, accuracy = 1),
      color = if_else(share > 0.3, "light", "dark")
    ),
    size = 4.5,
    fontface = "bold"
  ) +
  # a note to the right of any row whose numbers didn't add to 100
  geom_text(
    data = totals,
    aes(x = n_activities + 0.6, y = student, label = label),
    hjust = 0,
    size = 3.5,
    color = "#c92a2a"
  ) +
  scale_fill_gradient(low = "white", high = "#095339", guide = "none") +
  scale_color_manual(
    values = c(dark = "#222222", light = "white"),
    guide = "none"
  ) +
  # the x-axis is on top, and the tiles fill the whole plot area
  scale_x_discrete(position = "top", expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  coord_cartesian(clip = "off") + # let the notes print outside the plot
  labs(
    title = "How DAT 309 spends its week",
    caption = str_c(
      n_distinct(activities$student),
      " students. Each row adds up to 100%."
    ),
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold"),
    plot.title.position = "plot",
    plot.caption = element_text(color = "#777777", hjust = 0),
    plot.caption.position = "plot",
    plot.margin = margin(10, 140, 10, 10) # room on the right for the notes
  )

heatmap

# ---- 6. save it -------------------------------------------------------------------
# the height grows with the number of students
#ggsave(
#  "activities_heatmap.png",
#  heatmap,
#  width = 9,
#  height = 1.5 + 0.45 * n_distinct(activities$student),
#  dpi = 200,
#  bg = "white"
#)
