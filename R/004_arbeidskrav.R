library(tidyverse)
library(gptworkr)

emneplaner <- read_rds("data/emneplaner.Rds")

# code with gpt

prompt <- "Du får se emneplanen til et fag. Du skal telle opp hvor mange arbeidskrav det er av ulike typer. Ikke tell med eksamener og obligatorisk oppmøte.

# Svarformat

Svar med følgende liste, men fyll inn antall arbeidskrav og en kommaseparert liste i klammeparentes med korte beskrivelser av arbeidskravene.

Skriftlig = 
Muntlig = 
Multimodal =
Praktisk-estetisk = 
Aktivitet utenfor campus = 
Annet = 
"

arbeidskrav_4o_mini <- emneplaner |> 
  mutate(
    emnekode,
    gpt(
      data = fulltekst,
      instruction = prompt,
      model = "gpt-4o-mini"
    ),
    .keep = "none"
  )

arbeidskrav_4o <- emneplaner |> 
  mutate(
    emnekode,
    gpt(
      data = fulltekst,
      instruction = prompt,
      model = "gpt-4o"
    ),
    .keep = "none"
  )

arbeidskrav <- bind_rows(arbeidskrav_4o,arbeidskrav_4o_mini) |>
  select(emnekode, gpt_model, gpt_response) 

# parse data

## Input: a dataframe with emnekode and gpt_response
parse_arbeidskrav <- function(replies){
  replies |> 
    mutate(
      emnekode,
      Arbeidskravformat.2 = str_match(gpt_response,regex("Skriftlig = (?<n>\\d+)", ignore_case = TRUE))[,2],
      Arbeidskravformat.3 = str_match(gpt_response,regex("Muntlig = (?<n>\\d+)", ignore_case = TRUE))[,2],
      Arbeidskravformat.4 = str_match(gpt_response,regex("Multimodal = (?<n>\\d+)", ignore_case = TRUE))[,2],
      Arbeidskravformat.5 = str_match(gpt_response,regex("Praktisk-estetisk = (?<n>\\d+)", ignore_case = TRUE))[,2],
      Arbeidskravformat.6 = str_match(gpt_response,regex("Aktivitet utenfor campus = (?<n>\\d+)", ignore_case = TRUE))[,2],
      Arbeidskravformat.7 = str_match(gpt_response,regex("Annet = (?<n>\\d+)", ignore_case = TRUE))[,2],
    )
}

arbeidskrav <- arbeidskrav |>
  parse_arbeidskrav() |> 
  mutate(
    across(
      contains("Arbeidskrav"),
      as.integer
    )
  ) |> 
  rowwise() |> 
    mutate(Arbeidskravantall = sum(across(contains("Arbeidskrav")))
  ) |> 
  rename(
    koder = gpt_model
  ) |> 
  relocate(Arbeidskravantall, .before = Arbeidskravformat.2)

# load human data

humans <- read_rds("data/humans.Rds")

humans <- humans |>
  mutate(
    emnekode = Emnekode,
    koder
    ) |>
  select(
    emnekode,
    koder,
    Arbeidskravantall,
    starts_with("Arbeidskravformat")
  )

# join with gpt data

arbeidskrav <- arbeidskrav |> bind_rows(humans) |> arrange(emnekode)
  
write_rds(arbeidskrav, "data/arbeidskrav.Rds")

