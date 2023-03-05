# A scripts that scrapes data on the International Bartenders Association (IBA) 
# Official Cocktails from https://iba-world.com/category/iba-cocktails/ and
# dumps this to a CSV file while changing it as little as possible.

library(tidyverse)
library(rvest)

html_dir <- "html"
unlink(html_dir, recursive = TRUE)
dir.create(html_dir, recursive = TRUE, showWarnings = FALSE)

cocktails_index_path = file.path(html_dir, "cocktails-index.html")
download.file("https://iba-world.com/category/iba-cocktails/", cocktails_index_path)
cocktails_index_html <- read_html(cocktails_index_path)

cocktails_a <- html_elements(cocktails_index_html, ".entry-title a")
cocktails_scrape_info = tibble(
  name = html_text2(cocktails_a),
  url = html_attr(cocktails_a, "href"),
  html_path =  file.path(html_dir, paste0(str_extract(url, '[^/]+(?=/$)'), ".html"))
) 

walk2(cocktails_scrape_info$url, cocktails_scrape_info$html_path, download.file)
cocktails_scrape_info$html = map(cocktails_scrape_info$html_path, read_html)

extract_between <- function(string, start, end) {
    str_extract(string, regex(paste0("(?<=", start, ").+?(?=", end, ")"), dotall = TRUE) )
}

cocktails_raw <- cocktails_scrape_info |> 
  rowwise() |> 
  mutate(
    category = 
      html_text2(html_elements(html, ".et_pb_title_meta_container a")) |> 
        keep(\(x) x %in% c("The Unforgettables", "New Era Drinks", "Contemporary Classics")),
    content_text = html_text2(html_element(html, ".blog-post-content")),
    ingredients = extract_between(content_text, "INGREDIENTS", "METHOD"),
    method = extract_between(content_text, "METHOD", "GARNISH"),
    garnish = extract_between(content_text, "GARNISH", "(HISTORY|$)")
  ) |> 
  select(category, name, ingredients, method, garnish) |> 
  arrange(category, name)

write_csv(cocktails_raw,"iba-cocktails-raw.csv")



