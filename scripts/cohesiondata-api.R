read_csv("https://cohesiondata.ec.europa.eu/resource/3kkx-ekfq.csv?year=2021&$select=ms,year&$limit=3000")
read_csv("https://cohesiondata.ec.europa.eu/resource/3kkx-ekfq.csv?year=2021&$limit=3000&dimension_type=InterventionField")

library(tidyverse)
library(httr)

get_cohdata <- function(dataset_id, type = "csv", ...) {
  url <- parse_url("https://cohesiondata.ec.europa.eu")
  url$path <- paste0("resource/", dataset_id, ".", type)
  url$query <- list(...)
  url2 <- httr::build_url(url)
  print(url2)
  resp <- httr::GET(url2)
  read_csv(I(resp$content))
}

dt_s <- get_cohdata("3kkx-ekfq", ms = "CZ", `$limit` = 30, `$select` = '*')
dt <- get_cohdata("3kkx-ekfq", ms = "CZ", `$limit` = 3000, year = 2021,
                  dimension_type = "InterventionField",
                  `$select` = 'ms, fund, title, eu_eligible_expenditure_notional_climate_change, eu_elig_expenditure_declared_fin_data_notional')

dt |>
  rename(fin_total = eu_elig_expenditure_declared_fin_data_notional,
         fin_climate = eu_eligible_expenditure_notional_climate_change) |>
  summarise(across(starts_with("fin"), sum, na.rm = TRUE)) |>
  mutate(share = fin_climate/fin_total)

get_cohdata("3kkx-ekfq", `$query` = "SELECT ms, sum(eu_eligible_expenditure_notional_climate_change)/1e9 as climate, sum(eu_elig_expenditure_declared_fin_data_notional)/1e9 as total, climate/total as ratio where year == 2021 and dimension_type == 'InterventionField' group by ms order by MS")
dddd <- get_cohdata("3kkx-ekfq", `$query` = "SELECT ms, year, sum(eu_eligible_expenditure_notional_climate_change)/1e9 as climate, sum(eu_elig_expenditure_declared_fin_data_notional)/1e9 as total, climate/total as ratio where year > 2016 and dimension_type == 'InterventionField' group by ms, year order by ms")
dddd <- get_cohdata("3kkx-ekfq", `$query` = "SELECT ms, year, sum(eu_eligible_expenditure_notional_climate_change)/1e9 as climate, sum(eu_elig_expenditure_declared_fin_data_notional)/1e9 as total, climate/total as ratio where year = 2021 and dimension_type == 'InterventionField' group by ms, year order by ms")

dddd |>
  ggplot(aes(year, ratio, group = ms)) +
    geom_line()

library(glue)
glue_collapse(c("SELECT x", "FROM Y"), sep = " ")
