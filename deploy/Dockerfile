## kasiatemp/ng-update:shiny
## kasiatemp/carbon-intensity-shiny:latest

FROM rocker/shiny:latest
RUN install2.r --skipinstalled --error \
    rsconnect shiny shinyWidgets \
    dygraphs ggplot2 plotly xts  \
    here dplyr bslib stringr lubridate viridis \
    intensegRid logger \
    && rm -rf /tmp/downloaded_packages


