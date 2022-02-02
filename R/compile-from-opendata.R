source("_targets_packages.R")

compile_from_od <- function(ef_pub, efs_obl, efs_prj_sc, od_prj_sc) {

  ef_base <- ef_pub |> select(prj_id, starts_with("fin"),
                              starts_with("op_"), starts_with("p_"),
                              starts_with("dt_"), "real_stav")

  od_prj_sc <- od_prj_sc |>
    filter(!prj_id %in% efs_prj_sc$prj_id) |>
    group_by(prj_id) |>
    mutate(sc_podil = 1/n()) |>
    ungroup()

  efs_obl <- efs_obl |> select(prj_id, starts_with("oblast_intervence"))

  ef_obl <- ef_pub |>
    filter(!prj_id %in% efs_obl$prj_id) |>
    select(prj_id, starts_with("oblast_intervence")) |>
    separate_rows(oblast_intervence_kod, oblast_intervence_nazev, sep = ";") |>
    group_by(prj_id) |>
    mutate(oblast_intervence_podil = 1/n()) |>
    ungroup()

  sc  <- bind_rows(efs_prj_sc, od_prj_sc)
  obl <- bind_rows(efs_obl, ef_obl)

  rslt <- ef_base |>
    left_join(sc, by = "prj_id") |>
    left_join(obl, by = "prj_id") |>
    mutate(radek_podil = oblast_intervence_podil * sc_podil,
           across(starts_with("fin"), ~.x * radek_podil))

  return(rslt)

}
