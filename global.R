library(shiny)
library(dygraphs)
library(xts)
library(dplyr)
library(bslib)
library(here)
library(thematic)
library(stringr)
# library(patchwork)
# library(ggtext)
# library(glue)

# Default is use caching
if (getOption("cache", TRUE)) {
  bindCache <- shiny::bindCache
  print("Enabling caching")
} else {
  bindCache <- function(x, ...)
    x
  print("Disabling caching")
}

source("functions.R")
# Builds theme object to be supplied to ui
my_theme <- bs_theme(
  bootswatch = "cerulean",
  base_font = font_google("Righteous"),
  "font-size-base" = "1.1rem"
) %>%
  bs_add_rules(
    "
    #source_link {
      position: fixed;
      top: 5px;
      right: 5px;
      font-size: 0.9rem;
      font-weight: lighter;
    }"
  )

# Let thematic know to use the font from bs_lib
# thematic_on(font = "auto")

# data import and preprocessing 
# import carbon intensity data 
daily_ci <- readRDS(here("data/20210217-daily-ci.rds"))

# region helpers 
region_lookup <- daily_ci %>%
  select(regionid, shortname) %>%
  arrange(regionid) %>%
  select(shortname) %>%
  unique()

unique_regions <- unique(daily_ci$shortname)
