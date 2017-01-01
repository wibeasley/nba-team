rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
# source("./SomethingSomething.R")

# ---- load-packages -----------------------------------------------------------
library(ggplot2) #For graphing
library(magrittr) #Pipes
requireNamespace("knitr")
requireNamespace("scales") #For formating values in graphs
requireNamespace("RColorBrewer")
requireNamespace("dplyr")
# requireNamespace("tidyr") #For converting wide to long
# requireNamespace("mgcv, quietly=TRUE) #For the Generalized Additive Model that smooths the longitudinal graphs.
# requireNamespace("TabularManifest") # devtools::install_github("Melinae/TabularManifest")

# ---- declare-globals ---------------------------------------------------------
options(show.signif.stars=F) #Turn off the annotations on p-values

path_input <- "./data-phi-free/derived/team-shooting.rds"

# ---- load-data ---------------------------------------------------------------
ds <- readr::read_rds(path_input) # 'ds' stands for 'datasets'

# ---- tweak-data --------------------------------------------------------------

# ---- marginals ---------------------------------------------------------------
TabularManifest::histogram_discrete(ds, variable_name="defender_distance")
TabularManifest::histogram_discrete(ds, variable_name="team_name")
TabularManifest::histogram_discrete(ds, variable_name="team_id")

TabularManifest::histogram_continuous(ds, variable_name="fg_proportion")
TabularManifest::histogram_continuous(ds, variable_name="fg_made")
TabularManifest::histogram_continuous(ds, variable_name="fg_attempted")
TabularManifest::histogram_continuous(ds, variable_name="fg_percentage")
TabularManifest::histogram_continuous(ds, variable_name="fg_effective_percentage")

TabularManifest::histogram_continuous(ds, variable_name="fg2_proportion")
TabularManifest::histogram_continuous(ds, variable_name="fg2_made")
TabularManifest::histogram_continuous(ds, variable_name="fg2_attempted")
TabularManifest::histogram_continuous(ds, variable_name="fg2_percentage")

TabularManifest::histogram_continuous(ds, variable_name="fg3_proportion")
TabularManifest::histogram_continuous(ds, variable_name="fg3_made")
TabularManifest::histogram_continuous(ds, variable_name="fg3_attempted")
TabularManifest::histogram_continuous(ds, variable_name="fg3_percentage")


# This helps start the code for graphing each variable.
#   - Make sure you change it to `histogram_continuous()` for the appropriate variables.
#   - Make sure the graph doesn't reveal PHI.
#   - Don't graph the IDs (or other uinque values) of large datasets.  The graph will be worth and could take a long time on large datasets.
# for(column in colnames(ds)) {
#   cat('TabularManifest::histogram_continuous(ds, variable_name="', column,'")\n', sep="")
# }

# ---- scatterplots ------------------------------------------------------------
g1 <- ggplot(ds, aes(x=defender_distance, y=fg3_proportion, label=team_id, color=team_name, group=team_name)) +
  geom_line() +
  geom_text() +
  # geom_point(shape=1) +
  theme_light() +
  theme(axis.ticks = element_blank())
g1

g1 %+% aes(y=fg2_proportion)
g1 %+% aes(y=fg3_attempted)


# # ---- model-results-table  -----------------------------------------------
# knitr::kable(summary(m2)$coef, digits = 2, format="markdown", results = "asis")
# DT::datatable(round(summary(m2)$coef, digits = 2), options = list(pageLength = 2))
