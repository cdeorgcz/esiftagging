targets::tar_load(prj_tagcomparison)
targets::tar_load(starts_with("ef"))
targets::tar_load(starts_with("esif"))
targets::tar_load(starts_with("prv"))
targets::tar_load(starts_with("agri"))
targets::tar_load(data_for_tagging)

library(tidyverse)

prj_tagcomparison |>
  count(wt = fin_vyuct_czv * radek_podil)

efs_tags_compare |>
  count(wt = fin_vyuct_czv)

esif_tagged_sum |>
  count(wt = fin_vyuct_czv)

esif_mtagged_sum |>
  count(wt = fin_vyuct_czv)

agri_opendata |>
  count(wt = fin_vyuct_czv)

agri_tagged |>
  count(wt = fin_vyuct_czv)

prv_tagged_sum |>
  count(wt = fin_vyuct_czv)

agri_tagged_sum |>
  count(wt = fin_vyuct_czv)

efs_tagged |>
  count(wt = fin_vyuct_czv * radek_podil)

efs_mtagged |>
  count(wt = fin_vyuct_czv * radek_podil)

data_for_tagging |>
  count(wt = fin_vyuct_czv * radek_podil)

efs_mtagged_sum_prj |>
  count(wt = fin_vyuct_czv)

efs_tagged_sum_prj |>
  count(wt = fin_vyuct_czv)

ef_pub |> count(wt = fin_vyuct_czv)
