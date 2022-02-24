
make_prj_comparison <- function(efs_tagged, efs_mtagged) {
  left_join(
    efs_tagged,
    efs_mtagged |> select(prj_id, sc_id, oblast_intervence_kod, climate_share_m),
    by = c("prj_id", "sc_id", "oblast_intervence_kod")
  )
}

get_retagged_prj <- function(efs_tags_compare_prj, ef_pub) {
  efs_tags_compare_prj |>
    filter(fin_pravniakt_czv > 0) |>
    filter(climate_share != climate_share_m) |>
    select(prj_id, fin_pravniakt_czv, fin_vyuct_czv, p_nazev, starts_with("climate")) |>
    left_join(ef_pub |> select(prj_id, prj_nazev, prj_shrnuti, op_zkr)) |>
    mutate(across(starts_with("fin"), ~./1e6)) |>
    arrange(-fin_vyuct_czv) |>
    mutate(retag = paste(if_else(climate_share < climate_share_m, "↑", "↓"),
                         climate_share * 100,
                         "→",
                         climate_share_m * 100))
}

sample_retagged <- function(retagged_prj) {
    retagged_prj_top <- retagged_prj |>
      group_by(retag, op_zkr) |>
      slice_max(fin_vyuct_czv, n = 20) |>
      mutate(typ = "největší")

    retagged_prj_random <- retagged_prj |>
      filter(!prj_id %in% retagged_prj_top$prj_id) |>
      group_by(retag, op_zkr) |>
      slice_sample(n = 20) |>
      mutate(typ = "náhodné")

    bind_rows(retagged_prj_top, retagged_prj_random)
}
