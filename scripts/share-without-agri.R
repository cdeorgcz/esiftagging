targets::tar_load(esif_tagged_sum)

esif_tagged_sum |>
  filter(op_zkr != "PRV") |>
  replace_na(list(climate_share = 0)) |>
  summarise(total = sum(fin_vyuct_eu, na.rm = TRUE)/1e9,
            total_eur = total / 24.4,
            climate = sum(fin_vyuct_eu * climate_share, na.rm = T)/1e9,
            climate_eur = climate / 24.4) |>
  mutate(share = climate/total)
