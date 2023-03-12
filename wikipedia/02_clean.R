library(tidyverse)
library(tidyr)
library(tools)
library(jsonlite)

base_dir <- "wikipedia"
cocktails_raw <- read_csv(file.path(base_dir, "iba-cocktails-wiki-raw.csv"))

cocktails <- cocktails_raw |> 
  rename(
    ingredients = iba_specifiedingredients,
    method = preparation
  ) |> 
  mutate(
    across(everything(), str_trim),
    across(everything(), \(x) str_replace_all(x, "’", "'")),
    ingredients = ingredients |> 
      str_replace("Lemon Juice, fresh", "Lemon Juice") |> 
      str_replace_all("\n", ",") |> 
      str_replace_all("mL", "ml") |> 
      str_replace_all("\\s+", " "),
    method = method |> 
      str_replace_all("\\[[^\\]]+\\]", "")
  )

cocktail_ingredients <- cocktails |> 
  select(category, name, ingredients) |> 
  separate_rows(ingredients, sep=",") |> 
  rename(ingredient = ingredients)

cocktails_nested_ingredients <- cocktails |> 
  select(-ingredients) |> 
  inner_join(
    cocktail_ingredients |> 
      group_by(name) |> 
      summarise(ingredients = list(ingredient))
  )

write_csv(cocktails, file.path(base_dir, "iba-cocktails-wiki.csv"))
write_csv(cocktail_ingredients, file.path(base_dir, "iba-cocktails-ingredients-wiki.csv"))
write_json(cocktails_nested_ingredients, file.path(base_dir, "iba-cocktails-wiki.json"), dataframe = 'rows', pretty = T)
