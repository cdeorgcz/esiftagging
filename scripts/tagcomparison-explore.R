targets::tar_load(prj_tagcomparison)
targets::tar_load(ef_pub)

prj_tagcomparison |>
  filter(climate_share_m < climate_share) |>
  filter(sc_id == "01.3.10.3.2",
         oblast_intervence_nazev_en == "Renewable energy: solar") |>
  left_join(ef_pub |> distinct(prj_id, prj_nazev, prj_shrnuti)) |>
  select(prj_nazev, prj_shrnuti, radek_podil, p_nazev, fin_vyuct_czv) |> View()

targets::tar_load(reg_table_nonagri)

reg_table_nonagri |> filter(oblast_intervence_kod == "IV.1.065") |>
  pull(1)
