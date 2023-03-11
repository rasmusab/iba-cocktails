#/bin/bash
# Adding --platform linux/amd64 might be needed if you're on a new Mac.
docker run --rm \
  -v $(pwd):/tmp/working_dir \
  -w /tmp/working_dir \
  rocker/tidyverse:4.2.2 \
  sh -c "Rscript iba-web/01_scrape.R && Rscript iba-web/02_clean.R"