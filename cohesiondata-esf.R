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
dt <- get_cohdata("3kkx-ekfq", ms = "CZ", `$limit` = 3000, year = 2021, cci = "2014CZ05M9OP001",
                  dimension_type = "EsfSecondaryTheme",
                  `$select` = 'ms, priority, cci, fund, title, dimension_title, total_elig_expenditure_declared_fin_data, planned_total_amount_notional, planned_eu_amount')

dt |>
  count(`prioritní osa` = priority, dimension_title,
        wt = total_elig_expenditure_declared_fin_data/1e9, name = "spend EUR") |>
  ggplot(aes(`spend EUR`, as.factor(`prioritní osa`) |> fct_rev())) +
  geom_col() +
  ptrr::theme_ptrr("x", axis_titles = T) + labs(y = "Prioritní osa OP Z")

dt |>
  rename(fin_total = eu_elig_expenditure_declared_fin_data_notional,
         fin_climate = eu_eligible_expenditure_notional_climate_change) |>
  summarise(across(starts_with("fin"), sum, na.rm = TRUE)) |>
  mutate(share = fin_climate/fin_total)

dt |> count(wt = total_elig_expenditure_declared_fin_data/1e9, name = "spent total EUR")
dt |> count(wt = planned_total_amount_notional/1e9, name = "planned total EUR")
dt |> count(wt = planned_eu_amount/1e9, name = "planned EU EUR")

get_cohdata("3kkx-ekfq", `$query` = "SELECT ms, sum(eu_eligible_expenditure_notional_climate_change)/1e9 as climate, sum(eu_elig_expenditure_declared_fin_data_notional)/1e9 as total, climate/total as ratio where year == 2021 and dimension_type == 'InterventionField' group by ms order by MS")
dddd <- get_cohdata("3kkx-ekfq", `$query` = "SELECT ms, year, sum(eu_eligible_expenditure_notional_climate_change)/1e9 as climate, sum(eu_elig_expenditure_declared_fin_data_notional)/1e9 as total, climate/total as ratio where year > 2016 and dimension_type == 'InterventionField' group by ms, year order by ms")

dddd |>
  ggplot(aes(year, ratio, group = ms)) +
  geom_line()
