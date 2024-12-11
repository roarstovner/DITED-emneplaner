library(tidyverse)

humans <- read_csv2("data-raw/human_coded_2024-12-05.csv")

humans <- humans |> 
  mutate(
    koder = case_match(
      var1,
      "somag3033@oslomet.no" ~ "human1",
      "carlemil@oslomet.no" ~ "human2",
      "trine.h.tovik@ntnu.no" ~ "human3"
    )
  )

write_rds(humans, file = "data/humans.Rds")
