make_plot_tagged_all <- function(esif_tagged_sum) {
  data <- esif_tagged_sum %>%
    mutate(climate_share_code = case_when(climate_share == 0 ~ "No tag",
                                          climate_share == 0.4 ~ "Partial (40%)",
                                          climate_share == 1 ~ "Full (100%)",
                                          is.na(climate_share) ~ "Unknown") %>%
             fct_relevel("Full (100%)", "Partial (40%)", "None", "Unknown") %>% fct_rev()) %>%
    group_by(climate_share_code) %>%
    count(op_zkr, wt = fin_vyuct_czv/1e9) %>%
    ungroup() %>%
    mutate(op_zkr = as_factor(op_zkr) %>% fct_reorder(n, "sum")) %>%
    arrange(op_zkr, desc(climate_share_code)) %>%
    group_by(op_zkr) %>%
    mutate(label_pos = cumsum(n),
           label_value = round(n, 0),
           label_value = if_else(label_value < 1.5, NA_real_, label_value))

  labels_total <- data %>%
    ungroup() %>%
    count(op_zkr, wt = n, name = "total") %>%
    mutate(label_value = round(total, 0))

  ggplot(data, aes(y = op_zkr)) +
    scale_fill_manual(values = c(`Full (100%)` = "darkgreen", `Partial (40%)` = "lightgreen",
                                 `No tag` = "darkgrey", Unknown = "lightgrey"), name = NULL) +
    geom_col(aes(x = n, fill = climate_share_code)) +
    scale_x_continuous(expand = ptrr::flush_axis) +
    theme_ptrr("x", legend.position = "bottom", legend.key.size = unit(10, "pt")) +
    geom_text(aes(label = label_value, x = label_pos), hjust = 1.5,
              colour = "white", family = "IBM Plex Sans") +
    geom_text(data = labels_total,
              aes(label = label_value, x = total), hjust = 0, nudge_x = 2,
              colour = "grey10", family = "IBM Plex Sans") +
    labs(title = "Spending by climate tags",
         subtitle = "bn CZK, all spending. Follows official climate tags.",
         caption = "Payment data for CZ-PL programme unavailable.")
}

make_plot_weighted_all <- function(esif_tagged_sum) {
  data <- esif_tagged_sum %>%

    count(op_zkr, wt = fin_vyuct_czv * climate_share / 1e9) %>%
    mutate(op_zkr = as_factor(op_zkr) %>% fct_reorder(n))

  ggplot(data, aes(y = op_zkr, x = n)) +
    geom_col(fill = "darkblue") +
    scale_x_continuous(expand = ptrr::flush_axis) +
    theme_ptrr("x", legend.position = "none") +
    geom_text(aes(label = round(n, 0)), hjust = 1.5,
              colour = "white", family = "IBM Plex Sans") +
    labs(title = "Total contribution to climate",
         subtitle = "bn CZK, all spending weighted by official climate tags.",
         caption = "Payment data for CZ-PL programme unavailable.")

}
make_plot_tagged_agri_detail <- function(agri_tagged) {
  agri_tagged %>%
    count(fond, typ_podpory, opatreni, climate_share, wt = fin_vyuct_czv/1e9) %>%
    mutate(opatreni = as.factor(opatreni) %>% fct_reorder(n, .fun = "sum")) %>%
    ggplot(aes(n, paste0(fond, "\n", typ_podpory), fill = n, group = opatreni)) +
    geom_col() +
    facet_grid(.~climate_share, labeller = label_both) +
    theme_ptrr("x", legend.position = "bottom", multiplot = T)
}

make_plot_tagged_agri <- function(agri_tagged) {
  agri_tagged %>%
    mutate(fond_typ = as_factor(paste0(fond, "\n", typ_podpory)) %>%
             fct_reorder(fin_vyuct_czv, "sum")) %>%
    count(fond_typ, opatreni, climate_share, wt = fin_vyuct_czv/1e9) %>%
    mutate(climate_share_code = case_when(climate_share == 0 ~ "none",
                                          climate_share == 0.4 ~ "partial (40%)",
                                          climate_share == 1 ~ "full (100%)",
                                          is.na(climate_share) ~ "unknown") %>%
             fct_relevel("full (100%)", "partial (40%)", "none", "unknown") %>% fct_rev()) %>%
    ggplot(aes(n, fond_typ, fill = climate_share_code)) +
    scale_x_continuous(expand = ptrr::flush_axis) +
    scale_fill_manual(values = c(`full (100%)` = "darkgreen", `partial (40%)` = "lightgreen",
                                 none = "darkgrey", unknown = "lightgrey"), name = NULL) +
    geom_col() +
    theme_ptrr("x", legend.position = "bottom", legend.key.size = unit(10, "pt")) +
    labs(title = "CAP spending by climate tags",
         subtitle = "bn CZK, all spending. Follows official climate tags.")
}
