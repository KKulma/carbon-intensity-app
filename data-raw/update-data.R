## connect to ADO DB
library(intensegRid)
library(dplyr)
library(lubridate)
library(logger)

data_path <- "data/daily-ci.rds"

transform_ci <- function(raw) {
  raw %>%
    dplyr::mutate(from_dt = lubridate::as_date(from),
                  is_renewable = dplyr::if_else(fuel %in% c("nuclear", "hydro", "solar", "wind"), 1, 0)) %>%
    dplyr::filter(is_renewable == 1) %>%
    dplyr::group_by(from, from_dt, regionid, dnoregion, shortname) %>%
    dplyr::summarise(total_perc = sum(perc)) %>% # calculate renewable perc by 1/2 hour interval
    dplyr::group_by(from_dt, regionid, dnoregion, shortname) %>%
    dplyr::summarise(renewable_perc = mean(total_perc)) %>%
    dplyr::ungroup()
}

#national CI
start <- lubridate::today() - lubridate::days(1)
end <- start

logger::log_info("pull data from the API")

intense_data <-
  intensegRid::get_national_ci(start = start, end = end)

logger::log_info("update rds file")
if (!is.null(intense_data)) {
  # export daily summary
  new_entries = transform_ci(intense_data)
  old_data <- readRDS(data_path)
  new_data <- rbind(old_data, new_entries)
  saveRDS(new_data, data_path)
  logger::log_info("update... DONE!")
}
