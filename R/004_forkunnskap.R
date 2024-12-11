library(tidyverse)
library(gptworkr)

emneplaner <- readRDS("data/emneplaner.Rds")

# dataene nedenfor er lagret i data/forkunnskap.Rda

forkunnskap_4o <- emneplaner |> mutate(
  emnekode,
  gpt(
    fulltekst,
    "Du får se emneplanen til et fag. Nevnes forkunnskapskrav eksplisitt? 
      
      # Svaralternativer
      
      Nei: Nei, ingen eksplisitte forkunnskapskrav ble nevnt.
      Ja: Ja, eksplisitte forkunnskapskrav ble nevnt.
      
      Svar kun med 'Ja' eller 'Nei', ingenting annet.",
    model = "gpt-4o",
    max_tokens = 1
  ),
  .keep = "none"
)

forkunnskap_4o_mini <- emneplaner |> mutate(
  emnekode,
  gpt(
    fulltekst,
    "Du får se emneplanen til et fag. Nevnes forkunnskapskrav eksplisitt? 
      
      # Svaralternativer
      
      Nei: Nei, ingen eksplisitte forkunnskapskrav ble nevnt.
      Ja: Ja, eksplisitte forkunnskapskrav ble nevnt.
      
      Svar kun med 'Ja' eller 'Nei', ingenting annet.",
    model = "gpt-4o-mini",
    max_tokens = 1
  ),
  .keep = "none"
)

forkunnskap_4o_CoT <- emneplaner |> mutate(
  emnekode,
  gpt(
  fulltekst,
  "Du får se emneplanen til et fag. Nevnes forkunnskapskrav eksplisitt? 
      
      # Svarformat
      
      På første linje svarer du kort med hva forkunnskapskravene er.
      
      På andre linje svarer du kun 'Ja' eller 'Nei', ingenting annet.
      Svar 'Nei' hvis ingen eksplisitte forkunnskapskrav ble nevnt.
      Svar 'Ja' hvis eksplisitte forkunnskapskrav ble nevnt.",
      model = "gpt-4o"),
  .keep = "none"
)

# create correct answer formats

parse_ja_nei <- function(replies){
  case_when(
    str_detect(replies,regex("ja",ignore_case = TRUE)) ~ "2",
    str_detect(replies,regex("ne",ignore_case = TRUE)) ~ "1",
    .default = "not found"
  )
}

parse_CoT_reason <- function(replies){
  str_extract(replies, regex("^.*"))
}

parse_CoT_reply <- function(replies){
  str_extract(replies, regex(".*$"))
}

load("data/forkunnskap.Rda")

forkunnskap_4o_mini <- forkunnskap_4o_mini |> mutate(emnekode, koder = gpt_model, Forkunnskapskrav = parse_ja_nei(gpt_response), .keep = "none")
forkunnskap_4o <-  forkunnskap_4o |> mutate(emnekode, koder = gpt_model, Forkunnskapskrav = parse_ja_nei(gpt_response), .keep = "none")
forkunnskap_4o_CoT <- forkunnskap_4o_CoT |> mutate(emnekode, koder = paste0(gpt_model,"-CoT"), Forkunnskapskrav = parse_ja_nei(parse_CoT_reply(gpt_response)), begrunnelse = parse_CoT_reason(gpt_response), .keep = "none")

forkunnskap_gpt <- bind_rows(forkunnskap_4o_mini, forkunnskap_4o, forkunnskap_4o_CoT) |> mutate(Forkunnskapskrav = as.double(Forkunnskapskrav))
rm(forkunnskap_4o_mini, forkunnskap_4o, forkunnskap_4o_CoT)

# merge with human coding

humans <- read_rds("data/humans.Rds")


forkunnskap <- humans |>
  mutate(
    emnekode = Emnekode,
    koder
    ) |>
  select(emnekode, koder, Forkunnskapskrav) |> 
  bind_rows(forkunnskap_gpt)

write_rds(forkunnskap, file = "data/forkunnskap.Rds")
