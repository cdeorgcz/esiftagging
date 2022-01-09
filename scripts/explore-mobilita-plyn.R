library(tidyverse)

prj <- efs_prj_sc |>
  filter(sc_id == "04.2.40.2.2") |>
  distinct(prj_id) |> pull()

efs_prj_basic |>
  filter(prj_id %in% prj) |>
  count(str_detect(prj_nazev, "LNG|CNG|[Pp]lyn"))

targets::tar_load(efs_fin)

efs_fin |>
  left_join(efs_prj_basic |> select(prj_id, prj_nazev)) |>
  filter(prj_id %in% prj) |>
  count(str_detect(prj_nazev, "LNG|CNG|[Pp]lyn"), wt = fin_vyuct_czv)

efs_fin |> add_op_labels() |> count(op_zkr, wt = fin_vyuct_czv)
