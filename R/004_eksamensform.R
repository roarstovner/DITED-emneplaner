library(tidyverse)
library(gptworkr)

emneplaner <- read_rds("data/emneplaner.Rds")

# code with gpt and save in 'eksamensform'

eksamensform_4o_mini <- emneplaner |>
  mutate(
    emnekode,
    gpt(
      data = fulltekst,
      instruction = "Du får se emneplanen til et fag. Du skal nevne alle eksamensformene som faget bruker som en kommaseparert liste.
      
  Mulige eksamensformer:
  
  Ingen
  Skriftlig hjemmeeksamen (f.eks. semesteroppgave, FoU-oppgave, masteroppgave)
  Skriftlig skoleeksamen
  Muntlig eksamen
  Praktisk eksamen (f.eks. konsert, kunstnerisk arbeid)
  Mappeeksamen (f.eks. fysisk mappe eller digital samling)
  Vurderingsrapport (f.eks. i praksis)
  Andre
  ",
      model = "gpt-4o-mini"
    )
  )

eksamensform_4o <- emneplaner |>
  mutate(
    emnekode,
    gpt(
      data = fulltekst,
      instruction = "Du får se emneplanen til et fag. Du skal nevne alle eksamensformene som faget bruker som en kommaseparert liste.
      
  Mulige eksamensformer:
  
  Ingen
  Skriftlig hjemmeeksamen (f.eks. semesteroppgave, FoU-oppgave, masteroppgave)
  Skriftlig skoleeksamen
  Muntlig eksamen
  Praktisk eksamen (f.eks. konsert, kunstnerisk arbeid)
  Mappeeksamen (f.eks. fysisk mappe eller digital samling)
  Vurderingsrapport (f.eks. i praksis)
  Andre
  ",
      model = "gpt-4o"
    )
  )
    
    
# parse to correct answer format

## Input: a dataframe with emnekode and gpt_response
parse_eksamensform <- function(replies){
  replies |> 
    mutate(
      emnekode,
      Eksamensform.1 = str_detect(gpt_response, regex("Ingen", ignore_case = FALSE)),
      Eksamensform.2 = str_detect(gpt_response, regex("Skriftlig hjemmeeksamen", ignore_case = FALSE)),
      Eksamensform.3 = str_detect(gpt_response, regex("Skriftlig skoleeksamen", ignore_case = FALSE)),
      Eksamensform.4 = str_detect(gpt_response, regex("Muntlig eksamen", ignore_case = FALSE)),
      Eksamensform.5 = str_detect(gpt_response, regex("Praktisk", ignore_case = FALSE)),
      Eksamensform.6 = str_detect(gpt_response, regex("Mappe", ignore_case = FALSE)),
      Eksamensform.7 = str_detect(gpt_response, regex("Vurderings", ignore_case = FALSE)),
      Eksamensform.8 = str_detect(gpt_response, regex("Andre", ignore_case = FALSE)),
    )
}

    
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
    starts_with("Eksamensform")
  )
      
# join with gpt data

eksamensform <- eksamensform_4o_mini |>
  bind_rows(eksamensform_4o) |> 
  select(emnekode, gpt_response, gpt_model) |> 
  parse_eksamensform() |> 
  mutate(koder = gpt_model) |> 
  bind_rows(humans) |> 
  arrange(emnekode)



write_rds(eksamensform, "data/eksamensform.Rds")
