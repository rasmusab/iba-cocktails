#/bin/bash
# Adding --platform linux/amd64 might be needed if you're on a new Mac.
docker run --rm \
  -v $(pwd):/tmp/working_dir \
  -w /tmp/working_dir \
  rocker/tidyverse:4.2.2 \
  sh -c "Rscript wikipedia/01_scrape.R && Rscript wikipedia/02_clean.R"