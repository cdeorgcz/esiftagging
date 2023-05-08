read_csv("https://cohesiondata.ec.europa.eu/resource/3kkx-ekfq.csv?year=2021&$select=ms,year&$limit=3000")
read_csv("https://cohesiondata.ec.europa.eu/resource/3kkx-ekfq.csv?year=2021&$limit=3000&dimension_type=InterventionField")

library(tidyverse)
library(httr)

lapply(list.files("R", full.names = TRUE, recursive = TRUE), source)

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

# 2021-27 -----------------------------------------------------------------

dt7 <- get_cohdata("hgyj-gyin", `$query` = "SELECT ms, sum(total_climate_amount)/1e9 as climate_total, sum(total_amount)/1e9 as total_total, climate_total/total_total as ratio where dimension_type == 'Intervention Field' group by ms, ms_name_en order by ms_name_en")

get_cohdata("hgyj-gyin", `$query` = "SELECT DISTINCT dimension_type where ms like 'CZ' LIMIT 10000")
get_cohdata("hgyj-gyin", `$query` = "SELECT DISTINCT ms, dimension_type where ms = 'CZ'")

# https://cohesiondata.ec.europa.eu/browse?category=2021+/+2027&limitTo=datasets&page=1

# https://cohesiondata.ec.europa.eu/2021-2027-Categorisation/2021-2027-Finances-details-categorisation-multi-fu/hgyj-gyin
dt7_cz <- get_cohdata("hgyj-gyin", `$query` = "SELECT total_climate_amount as climate_total, total_amount as total_total, climate_total/total_total as ratio where dimension_type = 'Intervention Field' and ms = 'CZ'")
dt7_cz <- get_cohdata("hgyj-gyin", `$query` = "SELECT * where dimension_type = 'Intervention Field' and ms = 'CZ'")
dt7_alldims_cz <- get_cohdata("hgyj-gyin", `$query` = "SELECT * where ms = 'CZ' LIMIT 5000")
dt7_cz_esf <- get_cohdata("hgyj-gyin", `$query` = "SELECT * where dimension_type = 'ESF Secondary Themes' and ms = 'CZ'")

dt7sub_cz <- dt7_cz |>
  select(programme_title_short, priority_code, priority_name, specific_objective_code, specific_objective_short_name,
         fund, starts_with("category"), total_amount, climate_weighting, total_climate_amount)

dt7_cz_esf |>
  count(category_name, wt = total_amount/1e6, sort = TRUE) |>
  mutate(percent = n/sum(n) * 100)

# Které balíky peněz (zde zřejmě SC)

length(unique(dt7sub_cz$specific_objective_short_name))
length(unique(dt7sub_cz$priority_name))

# Jak vypadají názvy a kódy prioritních os a specifických cílů?

dt7sub_cz |>
  distinct(programme_title_short, priority_name, priority_code,
           specific_objective_short_name,
           specific_objective_code) |>
  arrange(programme_title_short, priority_name, specific_objective_short_name) |>
  View()

dt7sub_cz |>
  ungroup() |>
  mutate(share_climate = total_climate_amount/sum(total_climate_amount, na.rm = TRUE),
         share_total = total_amount/sum(total_amount, na.rm = TRUE)) |>
  ggplot(aes(share_total, share_climate, colour = programme_title_short, size = total_amount)) +
  geom_point() +
  facet_wrap(~programme_title_short)

library(ggiraph)

plt <- dt7sub_cz |>
  count(programme_title_short, specific_objective_short_name, wt = total_climate_amount/1e9) |>
  ungroup() |>
  mutate(pgm = as.factor(programme_title_short) |> fct_reorder(n, .fun = sum)) |>
  ggplot(aes(n, pgm, fill = specific_objective_short_name, tooltip = specific_objective_short_name)) +
  geom_col_interactive() +
  guides(fill = "none")

girafe(ggobj = plt)

plt <- dt7sub_cz |>
  filter(climate_weighting > 0) |>
  count(programme_title_short, specific_objective_short_name, climate_weighting, wt = total_amount/1e9) |>
  ungroup() |>
  mutate(pgm = as.factor(programme_title_short) |> fct_reorder(n, .fun = sum)) |>
  ggplot(aes(n, pgm, fill = specific_objective_short_name,
             tooltip = paste(specific_objective_short_name, climate_weighting))) +
  geom_col_interactive() +
  guides(fill = "none")

girafe(ggobj = plt)

dt7sub_cz |>
  group_by(programme_title_short) |>
  summarise(climate = sum(total_climate_amount, na.rm = TRUE),
            total = sum(total_amount, na.rm = TRUE)) |>
  mutate(rest = total - climate) |>
  select(programme_title_short, rest, climate) |>
  pivot_longer(cols = c(rest, climate)) |>
  ggplot(aes(x = "", y = value, fill = name)) +
  facet_wrap(~programme_title_short) +
  geom_bar(stat = "identity", width = 1, color = "white", position = "fill") +
  coord_polar("y", start = 0, direction = -1)



dt7_alldims_cz |>
  group_by(dimension_type) |>
  skimr::skim()

metdata <- get_cohdata("hhu3-atyz")

dt7_cz |>
  filter(fund %in% c("ERDF", "CF", "ESF+")) |>
  distinct(programme_title_short,
           priority_name,
           priority_code,
           specific_objective_short_name,
           specific_objective_name,
           specific_objective_code) |>
  arrange(programme_title_short, priority_name, specific_objective_short_name) |>
  View()

