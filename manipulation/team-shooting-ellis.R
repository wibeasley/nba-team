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
path_out                       <- "data-phi-free/derived/team-shooting.csv"
figure_path <- 'stitched-output/manipulation/te/'

col_types <- readr::cols_only(
  `TEAM`              = readr::col_character(),
  `GP`                = readr::col_integer(),
  `G`                 = readr::col_integer(),
  `FREQ`              = readr::col_character(),
  `FGM`               = readr::col_double(),
  `FGA`               = readr::col_double(),
  `FG%`               = readr::col_double(),
  `EFG%`              = readr::col_double(),
  `2FG FREQ`          = readr::col_character(),
  `2FGM`              = readr::col_double(),
  `2FGA`              = readr::col_double(),
  `2FG%`              = readr::col_double(),
  `3FG FREQ`          = readr::col_character(),
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
    "team"                            = "`TEAM`"
    # , "games_played"                = "`GP`"
    , "game_count"                    = "`G`"
    , "fg_frequency"                  = "`FREQ`"
    , "fg_made"                       = "`FGM`"
    , "fg_attempted"                  = "`FGA`"
    , "fg_percentage"                 = "`FG%`"
    , "fg_effective_percentage"       = "`EFG%`"
    , "fg2_frequency"                 = "`2FG FREQ`"
    , "fg2_made"                      = "`2FGM`"
    , "fg2_attempted"                 = "`2FGA`"
    , "fg2_percentage"                = "`2FG%`"
    , "fg3_frequency"                 = "`3FG FREQ`"
    , "fg3_made"                      = "`3PM`"
    , "fg3_attempted"                 = "`3PA`"
    , "fg3_percentage"                = "`3P%`"
    , "defender_distance"             = "`Defender Distance`"
  )
