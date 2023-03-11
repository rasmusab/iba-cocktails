# A script that takes the "raw" IBA cocktail data, as produced by 01_scrape.R, and
# cleans this to produce three versions of this dataset:
# * `iba-cocktails.csv`: A CSV file with one row per cocktail. This means the ingredients
#   are all smushed into a single column as a comma separated list.
# * `iba-cocktails-ingredients.csv`: A CSV file with one row per cocktail ingredient. 
#   For example, there's three rows for the Margarita's Tequila, Triple Sec, and Lime 
#   Juice. Here each ingredient description have also been lightly parsed into its 
#   `quantity`, `unit`, and `ingredient`. For example, `15 ml Freshly Squeezed Lime Juice`
#   has `quantity`: `15`, `unit`: `ml`, and `ingredient`: `Freshly Squeezed Lime Juice`.
# * `iba-cocktails.json`: A JSON list with one dictionary/object per cocktail. This JSON
#   includes the combined information from `iba-cocktails.csv` and `iba-cocktails-ingredients.csv`.
#
# Some of the weirdness in this cleaning script is surely on me, but some of the weirdness
# here is also due to that there where many peculiarities with the data to begin with.

library(tidyverse)
library(tidyr)
library(tools)
library(jsonlite)

base_dir <- "iba-web" 
cocktails_raw <- read_csv(file.path(base_dir, "iba-cocktails-web-raw.csv"))

cocktails <- cocktails_raw |> 
  mutate(
    across(everything(), str_trim),
    across(everything(), \(x) str_remove_all(x, "\\*")),
    ingredients = ingredients |> 
      str_replace_all("(?<=\\d),(?=\\d)", ".") |>
      str_replace_all("\n", ",") |> 
      str_replace_all("\\s*,\\s*", ",") |> 
      str_replace_all("(\\d)([a-zA-Z])", "\\1 \\2") |> 
      str_replace_all("\\s+(?=\\d+ ml)", ","), #Special case for Lemon drop Martini 
    method = method |> 
      str_replace_all("\n", " "),
    garnish = garnish |> 
      str_replace_all("\n", " ") |> 
      na_if("N/A")
  )

split_ingredient_direction_regex = regex(ignore_case = TRUE, paste0(
  # quantity
  r"{^(few|a |\d+(?:\.|/|-)?\d*)?\s*}", 
  # unit
  r"{(ml|drops?|dashe?s?|pcs|tsp|teaspoons?|bar spoons?|table spoons?|top up|top|fill up|pinch|splash)?\s*}",
  # unit stop word
  r"{(?:with|of)?\s*}",
  # ingredient
  r"{([^(]+)\s*}",
  # note
  r"{(?:\((.+)\))?}"
))

cocktail_ingredients <- cocktails |> 
  select(category, name, ingredients) |> 
  separate_rows(ingredients, sep=",") |> 
  rename(ingredient_direction = ingredients) |> 
  mutate(
    str_match(ingredient_direction, split_ingredient_direction_regex)[, 2:5] |> 
      as_tibble(.name_repair = ~ c("quantity", "unit", "ingredient", "note"))
  ) |> 
  mutate(
    across(everything(), str_trim),
    across(c(quantity, unit), tolower),
    ingredient = case_match(ingredient,
      "sugar cube" ~ "Sugar Cube",                      
      .default = ingredient
    ),
    quantity = case_match(quantity,
      "a" ~ "1",
      "5/6" ~ "5-6",
      "6/8" ~ "6-8",
      NA ~ "1",
      .default = quantity
    ),
    unit = case_match(unit,
      "bar spoons" ~ "bar spoon",
      c("tsp", "teaspoons") ~ "teaspoon",
      "table spoon" ~ "tablespoon",
      "dashes" ~ "dash",
      "top" ~ "top up",
      "pcs" ~ "piece",
      NA ~ case_match(ingredient,
        "Celery Salt" ~ "dash",
        "Lime cut into small wedges" ~ "piece",
        "Mint Leaves" ~ "piece",
        "Pepper" ~ "dash",
        "Raw Egg White" ~ "piece",
        "Soda Water" ~ "top up",
        "Sugar Cube" ~ "piece",
        "Tabasco" ~ "dash",
        "fresh Mint sprigs" ~ "piece",
        "quarter size Sliced Fresh Ginger" ~ "piece",
        "strong Espresso" ~ "shot",
        "thin Slices Red Chili Pepper" ~ "piece"
      ),
      .default = unit
    )
  )

cocktails_nested_ingredients <- cocktails |> 
  select(-ingredients) |> 
  inner_join(
  cocktail_ingredients |> 
    rename(direction = ingredient_direction) |>  
    nest(ingredients = c(direction, quantity, unit, ingredient, note))
  )

write_csv(cocktails, file.path(base_dir, "iba-cocktails-web.csv"))
write_csv(cocktail_ingredients, file.path(base_dir, "iba-cocktails-ingredients-web.csv"))
write_json(
  cocktails_nested_ingredients, file.path(base_dir, "iba-cocktails-web.json"), 
  dataframe = 'rows', pretty = T
)
