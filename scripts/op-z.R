targets::tar_load(ef_pub)
targets::tar_load(efs_compiled_fin)
targets::tar_load(ef_compiled_fin)

ef_pub |>
  filter(op_zkr == "OP Z") |>
  count(prj_priorita_nazev, wt = fin_vyuct_czv/1e9) |>
  ggplot(aes(n, prj_priorita_nazev)) +
  geom_col()

priority <- ef_pub |>
  distinct(prj_id, op_zkr, prj_priorita_nazev)

efs_compiled_fin |>
  left_join(priority) |>
  filter(op_zkr == "OP Z") |>
  count(prj_priorita_nazev, wt = fin_vyuct_czv/1e9) |>
  ggplot(aes(n, prj_priorita_nazev)) +
  geom_col()
