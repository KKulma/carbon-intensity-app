#!/usr/bin/env bash

Rscript -e "source('data-raw/update-data.R')"


if [[ "$(git status --porcelain)" != "" ]]; then
    git config --global user.name 'Kasia'
    git config --global user.email 'katarzyna.kulma@gmail.com'
    git add data/*
    git commit -m "Auto update of the daily data"
    git push origin main
else
echo "Nothing to commit..."
fi


