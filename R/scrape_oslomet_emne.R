
# get structured data from top table of the webpage.
# Inputs an .html as a character value
# Returns a dataframe with six columns of data
oslomet_top_table <- function(emne_html){
  
  # add the header with emnekode and emnenavn
  
  clearfix <- rvest::read_html(emne_html) |> 
    rvest::html_element(".clearfix") |>
    rvest::html_text2()
  
  emnekode <- clearfix |> str_split_1(" ") |> _[1]
  emnenavn_norsk <- sub(".*? ","",clearfix)
  
  # then the data from the table, that is, the description list, dl
  
  dl <- rvest::read_html(emne_html) |>
    rvest::html_elements("dl")
  
  x <- tibble(
    name = dl |> rvest::html_elements("dt") |> rvest::html_text2(),
    value = dl |> rvest::html_elements("dd") |> rvest::html_text2() |> str_squish()
  ) |> 
    pivot_wider(
      names_from = name,
      names_prefix = "top_",
      values_from = value
    ) |> 
    janitor::clean_names()
    
    
  # create the final tibble
  
  x |>
    add_column(emnekode = emnekode, emnenavn_norsk = emnenavn_norsk) |> 
    rename(
      studiepoeng = top_omfang,
      top_emnekode = emnekode,
      top_emnenavn = top_engelsk_emnenavn
    ) |> 
    select(
      !top_pensum,
      !top_timeplan
    )
}

oslomet_all_text <- function(emne_html) {
  emne_html |>
    rvest::read_html() |>
    rvest::html_elements(".oslomet-margin-wrapper-top") |>
    rvest::html_text2() |>
    str_replace_all("  ", " ") |>
    str_replace_all("[\r]", "") |>
    str_replace_all("^[:space:]+", "") |>
    str_replace_all("[\n]+", "\n\n")
}

oslomet_sections <- function(emne_html){
  x <- rvest::read_html(emne_html) |>
    rvest::html_elements(".oslomet-margin-wrapper-top")
  
  tibble(
    section = x |> rvest::html_elements(".title-text") |> rvest::html_text2() |> str_squish(),
    text = x |> rvest::html_elements(".panel-body") |> rvest::html_text2() |> str_trim()
  ) |> 
    pivot_wider(names_from = section, names_prefix = "sec_", values_from = text) |> 
    janitor::clean_names()
}
