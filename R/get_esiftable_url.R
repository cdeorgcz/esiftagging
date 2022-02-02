library(rvest)

esif_list_tables <- function(base_url = "https://dotaceeu.cz/cs/statistiky-a-analyzy/seznamy-prijemcu") {
  h <- read_html(base_url)
  urls <- html_elements(h, "a.js-gtm-file-download") |>
    html_attr("href")
  labels <- html_elements(h, "a.js-gtm-file-download") |>
    html_text2()

  rslt <- tibble(text = labels, url = urls) |>
    mutate(text = str_squish(text),
           type = str_extract(tolower(urls), "xlsx?"),
           date = lubridate::parse_date_time(str_extract(text, "([0-9]{1,2}[\\./]\\s?)?[0-9]{1,2}[\\./]\\s?[0-9]{4}"),
                                             orders = c("dmy", "my")) |> as.Date(),
           type = if_else(str_detect(text, "PIK"), "PIK", "general"),
           url = if_else(str_detect(url, "^http"), url, paste0("https://mmr.cz", url)))

  return(rslt)
}

esif_get_table_entry <- function(tables_list, table_date = NULL, table_type = "general", ...) {
  if(missing(tables_list)) tables_list <- esif_list_tables(...)

  if(is.null(table_date)) table_date <- max(tables_list$date, na.rm = TRUE)

  tables_list <- tables_list |> filter(table_type == type)

  if(!table_date %in% tables_list$date) {
    table_date <- tables_list |>
      mutate(dd = abs(date - as.Date(table_date))) |>
      filter(dd == min(dd, na.rm = TRUE)) |>
      pull(date)
  }

  tables_list |> dplyr::filter(date == as.Date(table_date))
}

esif_get_table_url <- function(tables_list, table_date = NULL, table_type = "general", ...) {
  esif_get_table_entry(tables_list, table_date = NULL, table_type = "general", ...)$url
}

source("_targets_packages.R")
esif_get_table_url()
esif_get_table_entry()

date_from_url <- function(url) {
  tibble(url = url,
         date = str_extract(url, "20[12][0-9]_[0-9]{1,2}") |> lubridate::ym())
}

