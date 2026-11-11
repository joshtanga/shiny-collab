library(tidyverse)

mi26_raw <- read_tsv(
  "data/2026STATE_GENERAL_MI_CENR_BY_COUNTY.txt",
  skip = 1
) |>
  janitor::clean_names() |>
  filter(candidate_votes > 0)

gov <- mi26_raw |>
  filter(str_starts(office_description, "GOVERNOR")) |>
  select(county_name, party_description, candidate_last_name, candidate_votes)


candidates <- tribble(
  ~position                                                          , ~candidate_last_name ,
  "GOVERNOR AND LIEUTENANT GOVERNOR 4 YEAR TERM (1) POSITION"        , "Benson"             ,
  "GOVERNOR AND LIEUTENANT GOVERNOR 4 YEAR TERM (1) POSITION"        , "James"              ,
  "GOVERNOR AND LIEUTENANT GOVERNOR 4 YEAR TERM (1) POSITION"        , "Hudson"             ,
  "GOVERNOR AND LIEUTENANT GOVERNOR 4 YEAR TERM (1) POSITION"        , "Brandenburg"        ,
  "GOVERNOR AND LIEUTENANT GOVERNOR 4 YEAR TERM (1) POSITION"        , "Campbell"           ,
  "SECRETARY OF STATE 4 YEAR TERM (1) POSITION"                      , "Gilchrist"          ,
  "SECRETARY OF STATE 4 YEAR TERM (1) POSITION"                      , "Forlini"            ,
  "SECRETARY OF STATE 4 YEAR TERM (1) POSITION"                      , "Sloan"              ,
  "SECRETARY OF STATE 4 YEAR TERM (1) POSITION"                      , "Aughney"            ,
  "SECRETARY OF STATE 4 YEAR TERM (1) POSITION"                      , "Borregard"          ,
  "ATTORNEY GENERAL 4 YEAR TERM (1) POSITION"                        , "Savit"              ,
  "ATTORNEY GENERAL 4 YEAR TERM (1) POSITION"                        , "Lloyd"              ,
  "ATTORNEY GENERAL 4 YEAR TERM (1) POSITION"                        , "Dye"                ,
  "ATTORNEY GENERAL 4 YEAR TERM (1) POSITION"                        , "Ludtke"             ,
  "ATTORNEY GENERAL 4 YEAR TERM (1) POSITION"                        , "Polonowski"         ,
  "ATTORNEY GENERAL 4 YEAR TERM (1) POSITION"                        , "Dern"               ,
  "UNITED STATES SENATOR 6 YEAR TERM (1) POSITION"                   , "El-Sayed"           ,
  "UNITED STATES SENATOR 6 YEAR TERM (1) POSITION"                   , "Rogers"             ,
  "UNITED STATES SENATOR 6 YEAR TERM (1) POSITION"                   , "Christensen"        ,
  "UNITED STATES SENATOR 6 YEAR TERM (1) POSITION"                   , "Long"               ,
  "UNITED STATES SENATOR 6 YEAR TERM (1) POSITION"                   , "Marsh"              ,
  "UNITED STATES SENATOR 6 YEAR TERM (1) POSITION"                   , "Kristy"             ,
  "1ST DISTRICT REPRESENTATIVE IN CONGRESS 2 YEAR TERM (1) POSITION" , "Barr"               ,
  "1ST DISTRICT REPRESENTATIVE IN CONGRESS 2 YEAR TERM (1) POSITION" , "Bergman"            ,
  "1ST DISTRICT REPRESENTATIVE IN CONGRESS 2 YEAR TERM (1) POSITION" , "Satterla"           ,
  "1ST DISTRICT REPRESENTATIVE IN CONGRESS 2 YEAR TERM (1) POSITION" , "Kovaly"             ,
  "1ST DISTRICT REPRESENTATIVE IN CONGRESS 2 YEAR TERM (1) POSITION" , "Davenport"          ,
  "1ST DISTRICT REPRESENTATIVE IN CONGRESS 2 YEAR TERM (1) POSITION" , "Hakola"             ,
  "1ST DISTRICT REPRESENTATIVE IN CONGRESS 2 YEAR TERM (1) POSITION" , "Featherly"
)

# join to the county file read in earlier as mi26
mi26 <- mi26_raw |>
  # just democrats & republicans, unfortunately
  # change any non-democrat/republican party to "OTHER" (e.g., Libertarian, Green, etc.)
  mutate(
    party = str_to_title(if_else(
      party_description %in% c("DEMOCRATIC", "REPUBLICAN"),
      party_description,
      "OTHER"
    )),
    county = str_to_title(county_name),
    office = str_to_title(office_description),
    year = 2026
  ) |>
  select(
    party,
    office,
    county,
    year,
    candidate_last_name,
    candidate_votes
  )

# Remove any district information from the office name, so that we can combine all votes for the same office in a county
mi26 <- mi26 |>
  mutate(
    office = str_replace(office, ".*District ", ""),
    office = str_replace(office, ".*Circuit ", "")
  )


mi26 <- mi26 |>
  filter(
    str_detect(office, 'Governor') |
      str_detect(office, 'Representative') |
      str_detect(office, 'Senator'),
    !str_detect(office, 'University')
  )

mi26 <- mi26 |>
  group_by(county, office, party, year) |>
  summarize(
    votes = sum(candidate_votes)
  ) |>
  arrange(desc(votes))

mi26 <- mi26 |>
  pivot_wider(
    names_from = party,
    values_from = votes
  )

# get total of votes for each row
mi26 <- mi26 |>
  mutate(
    total = rowSums(across(c(Democratic, Republican, Other)), na.rm = TRUE),
    margin_votes = abs(Democratic - Republican),
    margin_pct = 100 * margin_votes / total,
    winner = if_else(Democratic > Republican, "Democratic", "Republican")
  )
