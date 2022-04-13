library(tidyverse)

options(scipen = 100)

# cdt <- read_csv("https://cohesiondata.ec.europa.eu/resource/3kkx-ekfq.csv")
# https://cohesiondata.ec.europa.eu/2014-2020-Categorisation/ESIF-2014-2020-categorisation-ERDF-ESF-CF-planned-/3kkx-ekfq
cdt2 <- read_csv("https://cohesiondata.ec.europa.eu/api/views/3kkx-ekfq/rows.csv?accessType=DOWNLOAD")

cdt2 |>
  count(`Financial Data Version`) |>
  arrange(desc(`Financial Data Version`))

tdt <- read_csv("https://cohesiondata.ec.europa.eu/api/views/gayr-92qh/rows.csv?accessType=DOWNLOAD")

tdt |>
  filter(Year == 2022) |>
  count(MS, wt = `Planned EU amount`/1e9, name = "planned_eu")
x
cdt2 |>
  filter(Year == 2021) |>
  count(`Member State (2 digit ISO)`,
        wt = `Spent EU Amount for Climate action (est.)`/1e9)

cdt_ms_yr <- cdt2 |>
  filter(TRUE,
         # Year == 2021,
         # `Member State (2 digit ISO)` == "CZ",
         TRUE) |>
  count(MS = `Member State (2 digit ISO)`, Year,
        wt = `Spent EU Amount for Climate action (est.)`/1e9,
        name = "climate")

adt_ms_yr <- cdt2 |>
  filter(Year == 2021, `Dimension Type` == "InterventionField") |>
  count(MS = `Member State (2 digit ISO)`, Year,
        wt = `Planned_Total_Amount_(Notional)`/1e9,
        name = "allocation_total")

table(cdt2$`Dimension Type`, useNA = "always")

cdt2 |>
  filter(Year == 2021,
         # `Dimension Type` == "FinanceForm",
         `Member State (2 digit ISO)` == "CZ",
         TRUE) |>
  count(MS = `Member State (2 digit ISO)`, Year,
        dim = `Dimension Type`,
        wt = `Planned EU Amount for Climate action`/1e9,
        name = "climate_total")



tdt_ms_yr <- tdt |>
  count(MS, Year, wt = `Total net payments`/1e9, name = "total")

srt <- tdt_ms_yr |>
  left_join(cdt_ms_yr) |>
  filter(Year == 2021) |>
  group_by(MS) |>
  transmute(srt = climate/total)

ttt <- tdt_ms_yr |>
  left_join(cdt_ms_yr) |>
  left_join(srt) |>
  ungroup() |>
  mutate(MS = as.factor(MS) |>
           fct_reorder(srt))

levels(ttt$MS)

ggplot(ttt, aes(Year, climate/total)) +
  geom_line() +
  geom_point(size = 0.5) +
  facet_wrap(~fct_rev(MS)) +
  ptrr::theme_ptrr("y", multiplot = T) +
  scale_x_continuous(limits = c(2016, 2021)) +
  ptrr::scale_y_percent_cz()

ggplot(ttt[ttt$Year == 2021,], aes(climate/total, MS)) +
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

