# IBA Cocktails in CSV and JSON format

This repo includes all the International Bartenders Association (IBA) Official Cocktails
in CSV and JSON format as of 2023. Included is also the R scripts I used to scrape this
data. These scripts are guaranteed to work on my computer, on then 5th of Match 2023, at
least once.

The files:
* `iba-cocktails.csv`: A CSV file with one row per cocktail. This means the ingredients 
   are all smushed into a single column as a comma separated list.
* `iba-cocktails-ingredients.csv`: A CSV file with one row per cocktail ingredient. 
   For example, there's three rows for the Margarita's Tequila, Triple Sec, and Lime 
   Juice. Here each ingredient description have also been lightly parsed into its 
   `quantity`, `unit`, and `ingredient`. For example, 
   `15 ml Freshly Squeezed Lime Juice` has `quantity`: `15`, `unit`: `ml`, and 
   `ingredient`: `Freshly Squeezed Lime Juice`.
* `iba-cocktails.json`: A JSON list with one dictionary/object per cocktail. This JSON
   includes the combined information from `iba-cocktails.csv` and 
   `iba-cocktails-ingredients.csv`.

If you want to run the scraping and cleaning script from scratch, you could either run
the scripts `01_scrape.R` and `02_clean.R` interactively, and hope that you just happen
to have the right version of R and required packages installed. Or if you have
[docker](https://www.docker.com/) installed you can run
`./dockerized_scrape_and_clean.sh`. However, if IBA changes their website just a _tiny_
bit from how it was on 2023-03-05 then these scripts are likely going to fail, anyway.