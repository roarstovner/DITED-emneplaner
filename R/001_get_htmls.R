library(tidyverse)

emner <- read_csv2("data-raw/emner.csv")

# Get all HTMLs from a tibble with emnekode and url column
htmls <- emner |>
  select(emnekode, url) |>
  pmap_df(
    \(emnekode, url) tibble(emnekode = emnekode, html = read_file(url)),
    .progress = TRUE
  )

saveRDS(htmls, file = "data/htmls.Rds")

# write all htmls to file
htmls |> pmap(\(emnekode, html) write_file(html,paste0(emnekode,".html")))


