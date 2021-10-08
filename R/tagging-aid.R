summarise_tagged <- function(data, ...) {
  data %>%
    group_by(oblast_intervence_nazev_en, oblast_intervence_kod,
             climate_share) %>%
    group_by(..., .add = TRUE) %>%
    # summarise(across(starts_with("fin_"), sum, na.rm = T)) %>%
    summarise(across(starts_with("fin_"), ~sum(.x * radek_podil, na.rm = TRUE)),
              n_prj = n_distinct(prj_id),
              .groups = "drop") %>%
    arrange(oblast_intervence_kod, ...)
}

summarise_tagged_op_only <- function(data_nonagri, data_prv) {
  bind_rows(data_prv, data_nonagri) %>%
    group_by(op_zkr, climate_share) %>%
    summarise(across(starts_with("fin_"), ~sum(.x, na.rm = TRUE)),
              .groups = "drop")
}

prep_tagged_for_plot <- function(efs_tagged_sum_op_sc) {
  efs_tagged_sum_op_sc %>%
    drop_na(climate_share) %>%
    filter(op_zkr != "OP ČR-PL") %>%
    group_by(climate_share, op_zkr, sc_nazev) %>%
    summarise(fin_vyuct_czv = sum(fin_vyuct_czv, na.rm = TRUE), .groups = "drop") %>%
    mutate(op_zkr = as_factor(op_zkr) %>% fct_reorder(fin_vyuct_czv, .fun = "sum")) %>%
    group_by(op_zkr) %>%
    mutate(sc_nazev = sc_nazev %>% str_wrap(30) %>%
             as_factor() %>%
             fct_reorder(fin_vyuct_czv),
           fin_vyuct_czv = round(fin_vyuct_czv/1e9, 1)) %>%
    rename(OP = op_zkr,
           `Spec. cíl` = sc_nazev,
           Klimatag = climate_share,
           `Výdaje (mld. Kč CZV)` = fin_vyuct_czv)
}

make_efs_plotly <- function(efs_tagged_for_plot) {
  ggplot(efs_tagged_for_plot) +
    geom_col(aes(x = `Výdaje (mld. Kč CZV)`, y = OP, group = `Spec. cíl`,
                 fill = `Výdaje (mld. Kč CZV)`, text = `Spec. cíl`)) +
    facet_wrap(~Klimatag, labeller = label_both) +
    guides(fill = "none") +
    theme_ptrr("x", multiplot = T, legend.position = "none")

  ggplotly(tooltip = c("x", "text"))
}

make_agri_plotly <- function(agri_tagged) {
  agri_tagged %>%
    mutate(fond_typ = as_factor(paste0(fond, "\n", typ_podpory)) %>%
             fct_reorder(fin_vyuct_czv, "sum")) %>%
    count(fond_typ, opatreni, climate_share, wt = fin_vyuct_czv/1e9) %>%
    mutate(opatreni = as.factor(opatreni) %>% fct_reorder(n, "sum"),
           n = round(n, 1)) %>%
    rename(Klimatag = climate_share,
           `Výdaje (mld. Kč CZV)` = n) %>%
    ggplot(aes(`Výdaje (mld. Kč CZV)`, fond_typ,
               fill = `Výdaje (mld. Kč CZV)`,
               text = opatreni)) +
    facet_wrap(~Klimatag, labeller = label_both, nrow = 1) +
    geom_col() +
    theme_ptrr("x", legend.position = "none", multiplot = TRUE)
  ggplotly(tooltip = c("x", "text"))
}
