get_cohdata <- function(dataset_id, type = "csv", ...) {
  url <- parse_url("https://cohesiondata.ec.europa.eu")
  url$path <- paste0("resource/", dataset_id, ".", type)
  url$query <- list(...)
  url2 <- httr::build_url(url)
  print(url2)
  resp <- httr::GET(url2)
  read_csv(I(resp$content))
}
