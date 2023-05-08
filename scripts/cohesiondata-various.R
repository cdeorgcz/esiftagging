library(tidyverse)

cdt <- read_csv("https://cohesiondata.ec.europa.eu/resource/3kkx-ekfq.csv")
cdt2 <- read_csv("https://cohesiondata.ec.europa.eu/api/views/3kkx-ekfq/rows.csv?accessType=DOWNLOAD")

cdt2 |> 
  count(`Financial Data Version`) |> 
  arrange(desc(`Financial Data Version`))

cdt2 |> 
  filter(Year == 2021) |> 
  count(`Member State (2 digit ISO)`, 
        wt = `Spent EU Amount for Climate action (est.)`/1e9) |> 
  View()

cdt_ms_yr <- cdt2 |> 
  # filter(Year == 2021) |> 
  count(MS = `Member State (2 digit ISO)`, Year,
        wt = `Spent EU Amount for Climate action (est.)`/1e9,
        name = "climate")

tdt <- read_csv("https://cohesiondata.ec.europa.eu/api/views/gayr-92qh/rows.csv?accessType=DOWNLOAD")

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
  ptrr::scale_y_percent_cz()

ggplot(ttt[ttt$Year == 2021,], aes(climate/total, MS)) +
  geom_col() +
  ptrr::theme_ptrr("x") +
  ptrr::scale_x_percent_cz()

sum(ttt$climate, na.rm = T)/sum(ttt$total, na.rm = T)
