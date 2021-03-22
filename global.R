library(shiny)
library(shinyWidgets)
library(dygraphs)
library(ggplot2)
library(plotly)
library(xts)
library(dplyr)
library(bslib)
library(here)
library(stringr)
library(lubridate)
library(viridis)


# Default is use caching
if (getOption("cache", TRUE)) {
  bindCache <- shiny::bindCache
  print("Enabling caching")
} else {
  bindCache <- function(x, ...)
    x
  print("Disabling caching")
}

# Builds theme object to be supplied to ui
my_theme <- bs_theme(bootswatch = "litera",
                     base_font = font_google("Merriweather Sans", local = TRUE)) # Arimo

# Let thematic know to use the font from bs_lib
# thematic_on(font = "auto")

# data import and preprocessing
# import carbon intensity data
daily_ci <- readRDS(here("data/daily-ci.rds"))

# region helpers
region_lookup <- daily_ci %>%
  select(regionid, shortname) %>%
  arrange(regionid) %>%
  select(shortname) %>%
  unique()

unique_regions <- unique(daily_ci$shortname)
