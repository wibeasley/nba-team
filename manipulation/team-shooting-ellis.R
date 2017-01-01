# knitr::stitch_rmd(script="./manipulation/te-ellis.R", output="./stitched-output/manipulation/te-ellis.md")
# For a brief description of this file see the presentation at
#   - slides: https://rawgit.com/wibeasley/RAnalysisSkeleton/master/documentation/time-and-effort-synthesis.html#/
#   - code: https://github.com/wibeasley/RAnalysisSkeleton/blob/master/documentation/time-and-effort-synthesis.Rpres
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these package(s) so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr, quietly=TRUE)

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("readr")
requireNamespace("tidyr")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.

# ---- declare-globals ---------------------------------------------------------
# Constant values that won't change.
path_in                        <- "data-phi-free/raw/team-shooting.csv"
path_out                       <- "data-phi-free/derived/team-shooting.rds"
figure_path <- 'stitched-output/manipulation/te/'

col_types <- readr::cols_only(
  `TEAM`              = readr::col_character(),
  `GP`                = readr::col_integer(),
  `G`                 = readr::col_integer(),
  `FREQ`              = readr::col_number(),
  `FGM`               = readr::col_double(),
  `FGA`               = readr::col_double(),
  `FG%`               = readr::col_double(),
  `EFG%`              = readr::col_double(),
  `2FG FREQ`          = readr::col_number(),
  `2FGM`              = readr::col_double(),
  `2FGA`              = readr::col_double(),
  `2FG%`              = readr::col_double(),
  `3FG FREQ`          = readr::col_number(),
  `3PM`               = readr::col_double(),
  `3PA`               = readr::col_double(),
  `3P%`               = readr::col_double(),
  `Defender Distance` = readr::col_character()
)


# ---- load-data ---------------------------------------------------------------
# Read the CSVs
ds      <- readr::read_csv(path_in, col_types=col_types)

ds

# ---- tweak-data --------------------------------------------------------------
# ds_nurse_month_ruralOklahoma <- ds_nurse_month_rural[ds_nurse_month_rural$HOME_COUNTY=="Oklahoma", ]

# OuhscMunge::column_rename_headstart(ds) #Spit out columns to help write call ato `dplyr::rename()`.
ds <- ds %>%
  dplyr::select_( #`select()` implicitly drops the 7 other columns not mentioned.
    "team_name"                       = "`TEAM`"
    # , "games_played"                = "`GP`"
    , "game_count"                    = "`G`"
    , "fg_frequency_percentage"       = "`FREQ`"
    , "fg_made"                       = "`FGM`"
    , "fg_attempted"                  = "`FGA`"
    , "fg_percentage"                 = "`FG%`"
    , "fg_effective_percentage"       = "`EFG%`"
    , "fg2_frequency_percentage"      = "`2FG FREQ`"
    , "fg2_made"                      = "`2FGM`"
    , "fg2_attempted"                 = "`2FGA`"
    , "fg2_percentage"                = "`2FG%`"
    , "fg3_frequency_percentage"      = "`3FG FREQ`"
    , "fg3_made"                      = "`3PM`"
    , "fg3_attempted"                 = "`3PA`"
    , "fg3_percentage"                = "`3P%`"
    , "defender_distance"             = "`Defender Distance`"
  ) %>%
  dplyr::mutate(
    defender_distance                 = ordered(defender_distance, levels=c("0-2", "2-4", "4-6", "Over 6")),
    fg_frequency                      = fg_frequency_percentage     / 100,
    fg_proportion                     = fg_percentage               / 100,
    fg2_frequency                     = fg2_frequency_percentage    / 100,
    fg2_proportion                    = fg2_percentage              / 100,
    fg3_frequency                     = fg3_frequency_percentage    / 100,
    fg3_proportion                    = fg3_percentage              / 100
  ) %>%
  dplyr::select(
    -fg_frequency_percentage, -fg_frequency,
    -fg2_frequency_percentage, -fg2_frequency,
    -fg3_frequency_percentage, -fg3_frequency
  )


# ---- team-id ----------------------------------------------------------
ds <- ds %>%
  dplyr::left_join(
    ds %>%
      dplyr::distinct(team_name, .keep_all = FALSE) %>%
      dplyr::arrange(team_name) %>%
      dplyr::mutate(
        team_id = seq_len(n())
      ),
     by = "team_name"
  ) %>%
  dplyr::arrange(defender_distance, team_id)


# ---- verify-values -----------------------------------------------------------
# Sniff out problems
# testit::assert("The month value must be nonmissing & since 2000", all(!is.na(ds$month) & (ds$month>="2012-01-01")))
# testit::assert("The county_id value must be nonmissing & positive.", all(!is.na(ds$county_id) & (ds$county_id>0)))
# testit::assert("The county_id value must be in [1, 77].", all(ds$county_id %in% seq_len(77L)))
# testit::assert("The region_id value must be nonmissing & positive.", all(!is.na(ds$region_id) & (ds$region_id>0)))
# testit::assert("The region_id value must be in [1, 20].", all(ds$region_id %in% seq_len(20L)))
# testit::assert("The `fte` value must be nonmissing & positive.", all(!is.na(ds$fte) & (ds$fte>=0)))
# # testit::assert("The `fmla_hours` value must be nonmissing & nonnegative", all(is.na(ds$fmla_hours) | (ds$fmla_hours>=0)))

testit::assert("The defender_distance-team_id combination should be unique.", all(!duplicated(paste(ds$defender_distance, ds$team_id))))

# ---- specify-columns-to-upload -----------------------------------------------
dput(colnames(ds)) # Print colnames for line below.
columns_to_write <- c(
  "defender_distance", "team_id", "team_name", "game_count",
  "fg_proportion" , "fg_made" , "fg_attempted" , "fg_percentage" , "fg_effective_percentage",
  "fg2_proportion", "fg2_made", "fg2_attempted", "fg2_percentage",
  "fg3_proportion", "fg3_made", "fg3_attempted", "fg3_percentage"
)

ds_slim <- ds %>%
  dplyr::select_(.dots=columns_to_write)
ds_slim


# ---- save-to-disk ------------------------------------------------------------
readr::write_rds(ds_slim, path_out)

#Possibly consider writing to sqlite (with RSQLite) if there's no PHI, or a central database if there is PHI.

