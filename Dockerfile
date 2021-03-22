FROM rocker/r-ver:4.0.3

RUN apt-get update \
   && apt-get install -y --no-install-recommends  \
      xml2 \
      openssl \
      curl \
      git \
      libcurl4-openssl-dev

# copy R scripts and install dependencies 
RUN R -e "install.packages('intensegRid');     if (!library(intensegRid, logical.return=T)) quit(status=10)" \
 && R -e "install.packages('dplyr');   if (!library(dplyr, logical.return=T)) quit(status=10)" \
 && R -e "install.packages('lubridate');   if (!library(lubridate, logical.return=T)) quit(status=10)" \
 && R -e "install.packages('logger');   if (!library(logger, logical.return=T)) quit(status=10)" 
#COPY data /home/data
#COPY data-raw /home/data-raw
