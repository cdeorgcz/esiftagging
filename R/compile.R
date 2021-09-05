efs_compile <- function(efs_prj_kat, efs_obl, efs_prj_sc) {

  efs_obl %>%
    left_join(efs_prj_kat, by = "prj_id") %>%
    full_join(efs_prj_sc, by = "prj_id") %>%
    select(prj_id, starts_with("katekon_"), starts_with("oblast_"),
           starts_with("sc_")) %>%
    mutate(radek_podil = oblast_intervence_podil * katekon_podil * sc_podil) %>%
    filter(radek_podil > 0)
}

efs_add_financials <- function(efs_compiled, efs_zop_bytime) {
  efs_compiled %>%
    full_join(efs_zop_bytime, by = "prj_id")
}

esif_summarise <- function(other, prv, quarterly, regional) {
  other$source <- "mssf"
  prv$source <- "prv"

  bnd <- bind_rows(other, prv) %>%
    replace_na(list(radek_podil = 1,
                      sc_podil = 1,
                      katekon_podil = 1,
                      oblast_intervence_podil = 1))

  grp <- bnd %>%
    group_by(dt_zop_rok, source)

  if (quarterly) {
    grp <- group_by(grp, dt_zop_kvartal, dt_zop_kvartal_datum, .add = TRUE)
  }


  rr <- grp %>%
    mutate(across(starts_with("fin_"), ~.x * radek_podil)) %>%
    summarise(across(starts_with("fin_"), sum, na.rm = TRUE), .groups = "drop")

  return(rr)
}
