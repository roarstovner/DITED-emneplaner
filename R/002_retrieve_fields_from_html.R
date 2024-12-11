library(tidyverse)

htmls <- readRDS("data/htmls.Rds")
emner <- read_csv2("data-raw/emner.csv")

source("R/scrape_oslomet_emne.R")

top_table <- htmls |> 
  pmap_df(\(emnekode,html) tibble(emnekode,oslomet_top_table(html)))

sections <- htmls |> 
  pmap_df(\(emnekode,html) tibble(emnekode, oslomet_sections(html)))
                                         
all_text <- htmls |> 
  pmap_df(\(emnekode,html) tibble(emnekode, fulltekst = oslomet_all_text(html)))

emneplaner <- reduce(list(emner,top_table, sections, all_text), left_join, by = "emnekode")

saveRDS(emneplaner, file = "data/emneplaner.Rds")
