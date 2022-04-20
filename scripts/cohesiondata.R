library(tidyverse)

options(scipen = 100)

# https://cohesiondata.ec.europa.eu/2014-2020-Categorisation/ESIF-2014-2020-categorisation-ERDF-ESF-CF-planned-/3kkx-ekfq
# ESIF 2014-2020 categorisation ERDF-ESF-CF planned vs implemented

# cdt <- read_csv("https://cohesiondata.ec.europa.eu/resource/3kkx-ekfq.csv")
ctg_planvsimpl <- read_csv("https://cohesiondata.ec.europa.eu/api/views/3kkx-ekfq/rows.csv?accessType=DOWNLOAD")
names(ctg_planvsimpl)

# https://cohesiondata.ec.europa.eu/2014-2020-Finances/ESIF-2014-2020-Finance-Implementation-Details/99js-gm52
finimpl <- read_csv("https://cohesiondata.ec.europa.eu/api/views/99js-gm52/rows.csv?accessType=DOWNLOAD")

finimpl |>
  filter(year == 2021, MS_name == "Czechia") |>
  count(wt = (total_eligible_spending * EU_co_financing/100)/1e9)

ctg_planvsimpl |>
  filter(Year == 2021, `Member State (2 digit ISO)` == "CZ", `Dimension Type` == "InterventionField") |>
  count(wt = `Planned_Total_Amount_(Notional)`/1e9)

ctg_planvsimpl |>
  count(`Financial Data Version`) |>
  arrange(desc(`Financial Data Version`))

# https://cohesiondata.ec.europa.eu/2014-2020-Finances/ESIF-2014-2020-EU-payments-daily-update-/gayr-92qh
# ESIF 2014-2020 EU payments (daily update)
pmts_daily <- read_csv("https://cohesiondata.ec.europa.eu/api/views/gayr-92qh/rows.csv?accessType=DOWNLOAD")
names(pmts_daily)

pmts_daily |>
  filter(Year == 2022) |>
  count(MS, wt = `Planned EU amount`/1e9, name = "total_eu_planned")

pmts_daily |>
  filter(Year == 2022, MS == "CZ") |>
  count(Fund, wt = `Total net payments`/1e9)

ctg_planvsimpl |>
  filter(Year == 2021) |>
  count(`Member State (2 digit ISO)`,
        wt = `Spent EU Amount for Climate action (est.)`/1e9)

ctg_planvsimpl_ms_yr <- ctg_planvsimpl |>
  filter(TRUE,
         # Year == 2021,
         # `Member State (2 digit ISO)` == "CZ",
         `Dimension Type` == "InterventionField",
         TRUE) |>
  group_by(MS = `Member State (2 digit ISO)`, Year) |>
  summarise(climate_eu_spent = sum(`Spent EU Amount for Climate action (est.)`, na.rm = T)/1e9,
            total_eu_spent = sum(`EU_spend_share_(Elig_Expenditure_Declared_notional)`, na.rm = T)/1e9,
            total_all_spent = sum(`Total_spend_(Elig_Expenditure_Declared)`, na.rm = T)/1e9,
            .groups = "drop") |>
  mutate(climate_share_eu = climate_eu_spent/total_eu_spent)

ctg_planvsimpl_ms_yr |>
  filter(Year == 2021) |>
  mutate(MS = fct_reorder(MS, climate_share_eu)) |>
  ggplot(aes(climate_share_eu, MS)) +
  geom_col()

adt_ms_yr <- ctg_planvsimpl |>
  filter(Year == 2021, `Dimension Type` == "InterventionField") |>
  count(MS = `Member State (2 digit ISO)`, Year,
        wt = `Planned_Total_Amount_(Notional)`/1e9,
        name = "total_all_allocation")

table(ctg_planvsimpl$`Dimension Type`, useNA = "always")

ctg_planvsimpl |>
  filter(Year == 2021,
         # `Dimension Type` == "FinanceForm",
         `Member State (2 digit ISO)` == "CZ",
         TRUE) |>
  count(MS = `Member State (2 digit ISO)`, Year,
        dim = `Dimension Type`,
        wt = `Planned EU Amount for Climate action`/1e9,
        name = "climate_eu_planned")



pmts_ms_yr <- pmts_daily |>
  count(MS, Year, wt = `Total net payments`/1e9, name = "total_eu_spent")

srt <- tdt_ms_yr |>
  left_join(cdt_ms_yr) |>
  filter(Year == 2021) |>
  group_by(MS) |>
  transmute(climate_share = climate_eu_spent/total_eu_spent)

ttt <- tdt_ms_yr |>
  left_join(cdt_ms_yr) |>
  left_join(srt) |>
  ungroup() |>
  mutate(MS = as.factor(MS) |>
           fct_reorder(climate_share))

levels(ttt$MS)

ggplot(ttt, aes(Year, climate/total)) +
  geom_line() +
  geom_point(size = 0.5) +
  facet_wrap(~fct_rev(MS)) +
  ptrr::theme_ptrr("y", multiplot = T) +
  scale_x_continuous(limits = c(2016, 2021)) +
  ptrr::scale_y_percent_cz()

ggplot(ttt[ttt$Year == 2021,], aes(climate_share, MS)) +
  geom_col() +
  ptrr::theme_ptrr("x") +
  ptrr::scale_x_percent_cz()

sum(ttt$climate, na.rm = T)/sum(ttt$total, na.rm = T)



# https://cohesiondata.ec.europa.eu/2014-2020-Categorisation/ESIF-2014-2020-categorisation-ERDF-ESF-CF-planned/9fpg-67a4
aaa <- read_csv("https://cohesiondata.ec.europa.eu/api/views/9fpg-67a4/rows.csv?accessType=DOWNLOAD")
table(aaa$`Dim Type`)
aaa |>
  filter(`Ctry Code` == "CZ") |>
  count(`Ctry Code`, Fund, wt = planned_total_amount_climate_action/1e9)

aaa |>
  filter(`Ctry Code` == "CZ") |>
  count(`Ctry Code`, `Dim Type`, wt = planned_total_amount_climate_action/1e9)

# https://cohesiondata.ec.europa.eu/2014-2020-Finances/ESIF-2014-2020-Finance-Implementation-Details/99js-gm52
aa2 <- read_csv("https://cohesiondata.ec.europa.eu/api/views/99js-gm52/rows.csv?accessType=DOWNLOAD")

aa2 |>
  filter(ms == "CZ", year == 2021) |>
  count(Fund, wt = Total_Amount_planned/1e9)

