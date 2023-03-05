#/bin/bash
docker run --rm \
  -v $(pwd):/tmp/working_dir \
  -w /tmp/working_dir \
  --platform linux/amd64 \
  rocker/tidyverse:4.2.2 \
  sh -c "Rscript 01_scrape.R && Rscript 02_clean.R"