# A scripts that scrapes data on the International Bartenders Association (IBA) 
# Official Cocktails from https://en.wikipedia.org/wiki/List_of_IBA_official_cocktails
# and dumps this to a CSV file while changing it as little as possible.

library(tidyverse)
library(rvest)

base_dir <- "wikipedia" 
html_dir <- file.path(base_dir, "html")
unlink(html_dir, recursive = TRUE)
dir.create(html_dir, recursive = TRUE, showWarnings = FALSE)

iba_cocktails_page_path = file.path(html_dir, "List_of_IBA_official_cocktails.html")
download.file("https://en.wikipedia.org/wiki/List_of_IBA_official_cocktails", iba_cocktails_page_path)
iba_cocktails_page_html <- read_html(iba_cocktails_page_path)


get_cocktail_category_names_and_links <- function(category) {
  a_tags <- html_elements(
    iba_cocktails_page_html, 
    xpath = paste0("//h3[normalize-space(./span) = '", category, "']/following-sibling::dl[1]/dt/a")
  )
  tibble(
    name = html_text2(a_tags), 
    url = paste0("https://en.wikipedia.org", html_attr(a_tags, "href"))
  )
}

iba_cocktails_page_info <- tibble(category = c("The unforgettables", "Contemporary classics", "New era drinks")) |> 
  group_by(category) |> 
  reframe(get_cocktail_category_names_and_links(category)) |> 
  mutate(
    base_path = url |> str_extract('[^/]+$') |> str_remove_all("\\W"),
    html_path = file.path(html_dir, paste0(base_path, ".html"))
  )

walk2(iba_cocktails_page_info$url, iba_cocktails_page_info$html_path, download.file)
iba_cocktails_page_info$html = map(iba_cocktails_page_info$html_path, read_html)

extract_from_info_table <- function(html, drink_name) {
  xpath_drink_name <- drink_name |> 
    case_match(
      "Lemon drop martini" ~ "Lemon drop",
      "Southside" ~ "South Side or Southside",
      "Clover Club" ~ "Clover Club cocktail",
      "Last word" ~ "The Last Word",
      "Ramos fizz" ~ "Ramos gin fizz",
      .default = drink_name
    ) |> 
    tolower() 
  raw_table <- html_element(html, xpath = paste0("//table[ normalize-space(translate(./caption, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')) = \"", xpath_drink_name, "\"]")) |> 
    html_table(header = FALSE) 
  fields <- raw_table$X2
  names(fields) <- raw_table$X1
  fields_to_keep <- c("Type", "Served", "Standard drinkware", "IBA specifiedingredients", "Preparation", "Notes")
  fields |> 
    as.list() |> 
    discard(~ .x == "") |> 
    as_tibble() |> 
    select(any_of(fields_to_keep))
}

cocktails_raw <- iba_cocktails_page_info |> 
  group_by(category, name) |> 
  reframe(extract_from_info_table(html[[1]], name[[1]])) |> 
  mutate(across(everything(), str_trim)) |> 
  rename_with( ~ .x |> tolower() |> str_replace_all("\\s+", "_"))

write_csv(cocktails_raw,  file.path(base_dir, "iba-cocktails-wiki-raw.csv"))
