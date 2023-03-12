# IBA Cocktails in CSV and JSON format

This repo includes all the International Bartenders Association (IBA) Official Cocktails in CSV and JSON format as of 2023, from two different sources: [The IBA website](https://iba-world.com/category/iba-cocktails/) and [Wikipedia's list of IBA cocktails](https://en.wikipedia.org/wiki/List_of_IBA_official_cocktails). My take on the difference between these sources is that the IBA website is more "official" (it's their list, after all), but the Wikipedia recipes are easier to follow.

Files scraped from [The IBA website](https://iba-world.com/category/iba-cocktails/) that you'll find in the [`iba-web`](iba-web) folder:

-   [`iba-cocktails-web.csv`](iba-web/iba-cocktails-web.csv): A CSV file with one row per cocktail. This means the ingredients are all smushed into a single column as a comma-separated list.
-   [`iba-cocktails-ingredients-web.csv`](iba-web/iba-cocktails-ingredients-web.csv): A CSV file with one row per cocktail ingredient. For example, there are three rows for the Margarita's (1) tequila, (2) triple sec, and (3) lime juice. Here each ingredient description has also been lightly parsed into its `quantity`, `unit`, and `ingredient`. For example, `15 ml Freshly Squeezed Lime Juice` has `quantity`: `15`, `unit`: `ml`, and `ingredient`: `Freshly Squeezed Lime Juice`.
-   [`iba-cocktails-web.json`](iba-web/iba-cocktails-web.json): A JSON list with one dictionary/object per cocktail. This JSON includes the combined information from [`iba-cocktails-web.csv`](iba-web/iba-cocktails-web.csv) and [`iba-cocktails-ingredients-web.csv`](iba-web/iba-cocktails-ingredients-web.csv).

Files scraped from [Wikipedia's list of IBA cocktails](https://en.wikipedia.org/wiki/List_of_IBA_official_cocktails) that you'll find in the  [`wikipedia`](wikipedia) folder:

-   [`iba-cocktails-wiki.csv`](wikipedia/iba-cocktails-wiki.csv): A CSV file with one row per cocktail. The ingredients are smushed into a single column as a comma-separated list.
-   [`iba-cocktails-ingredients-wiki.csv`](wikipedia/iba-cocktails-ingredients-wiki.csv): A CSV file with one row per cocktail ingredient. As Wikipedia has more "varying" ingredient descriptions than the IBA website, I wasn't able to parse these ingredient descriptions further.
-   [`iba-cocktails-wiki.json`](wikipedia/iba-cocktails-wiki.json): A JSON list with one dictionary/object per cocktail. This JSON includes the combined information from [`iba-cocktails-wiki.csv`](wikipedia/iba-cocktails-wiki.csv) and [`iba-cocktails-ingredients-wiki.csv`](wikipedia/iba-cocktails-ingredients-wiki.csv).

Included here are also the R scripts I used to scrape this data. These scripts are guaranteed to work on my computer, on the 5th of Match 2023, at least once.

If you want to run the scraping and cleaning script from scratch, you could either run the scripts `01_scrape.R` and `02_clean.R` interactively, and hope that you just happen to have the right version of R and the required packages installed. Or, if you have [docker](https://www.docker.com/) installed, you can run `./dockerized-scrape-iba-web.sh` and `dockerized-scrape-iba-wikipedia.sh`. However, if Wikipedia changes or IBA changes their website just a *tiny* bit from how it was on 2023-03-05 then these scripts are likely going to fail, anyway.

Also, see [teijo/iba-cocktails](https://github.com/teijo/iba-cocktails) for another IBA cocktails dataset.
