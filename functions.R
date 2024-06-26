
ref_table <- function(bibtexkeys) {
  suppressWarnings(library(bib2df))
  library(magrittr)
  library(data.table)
  path_bib <- here::here("references.bib")
  df_bib <- bib2df(path_bib)
  df_bib_out <- df_bib %>%
    setDT(.) %>%
    .[BIBTEXKEY %in% bibtexkeys] %>%
    .[, c("BIBTEXKEY", "TITLE", "NOTE", "URL")] %>%
    # .[, num_authors := sapply(AUTHOR, length)] %>%
    # .[, AUTHOR := sapply(AUTHOR, "[[", 1)] %>%
    # .[num_authors > 1, AUTHOR := paste(AUTHOR, "et al.")] %>%
    .[, BIBTEXKEY := paste0("@", BIBTEXKEY)] %>%
    .[, License := gsub("\\. Source: .*", "", NOTE)] %>%
    .[, License := gsub("License: \\\\href\\{([^}]+)\\}\\{([^}]+)\\}", "[\\2](\\1)", License)] %>%
    .[, Source := gsub(".*Source: (\\\\url\\{([^}]+)\\}).*", "\\2", NOTE)] %>%
    .[, Website := gsub(".*Website: (\\\\url\\{([^}]+)\\}).*", "\\2", NOTE)] %>%
    .[!(is.na(Website)), Website := sprintf("[{{< fa display >}}](%s)", Website)] %>%
    .[!(is.na(Source)), Source := sprintf("[{{< fa brands github >}}](%s)", Source)] %>%
    setnames(., old = c("BIBTEXKEY", "TITLE"), new = c("Authors", "Title")) %>%
    .[, c("Authors", "Title", "Website", "License", "Source")]
  return(df_bib_out)
}

table_cheatsheet <- function(name = "all") {
  library("here")
  library("magrittr")
  library("jsonlite")
  json_data <- jsonlite::fromJSON(txt = here::here("cheatsheet.json"))
  df <- json_data %>%
    dplyr::bind_rows(.id = "Chapter") %>%
    tidyr::pivot_longer(cols = -c("Chapter"), names_to = "Command", values_to = "Description") %>%
    transform(Command = sprintf("`%s`", Command)) %>%
    na.omit(.)
  if (name != "all") {
    df <- df %>%
      subset(., Chapter == name) %>%
      subset(., select = c(Command, Description))
  }
  return(df)
}

table_courses <- function() {
  library("yaml")
  library("here")
  library("magrittr")
  library("data.table")
  dt_input <- data.table::rbindlist(yaml::read_yaml("_courses.yml")$courses, fill = TRUE)
  dt_output <- dt_input %>%
    setnames(., old = "name", new = "Course Name") %>%
    setnames(., old = "number", new = "Number of Participants") %>%
    setnames(., old = "audience", new = "Target Audience") %>%
    setnames(., old = "date", new = "Date") %>%
    setnames(., old = "location", new = "Location") %>%
    .[, website := sprintf("[{{< fa display >}}](%s)", website)] %>%
    setnames(., old = "website", new = "Website")
  return(dt_output)
}
