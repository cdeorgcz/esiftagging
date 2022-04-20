source("_targets_packages.R")

make_tag_sankey <- function(data) {
  sdf2 <- make_long(data, climate_share, climate_share_m, value = fin_vyuct_czv) |>
    mutate(node = fct_relevel(node, "Full (100%)", "Partial (40%)", "No tag",
                              "Negative (-40%)", "Negative (-100%)") %>% fct_rev(),
           next_node = fct_relevel(next_node, "Full (100%)", "Partial (40%)", "No tag",
                                   "Negative (-40%)", "Negative (-100%)") %>% fct_rev()) |>
    filter(value > 0)
  ggplot(sdf2, aes(x = x,
                   next_x = next_x,
                   node = node,
                   node.color = node,
                   next_node = next_node,
                   fill = node,
                   value = value)) +
    geom_sankey(width = .4,
                flow.alpha = .6, na.rm = TRUE) +
    geom_sankey_text(aes(label = node,
                         colour = after_scale(cr_choose_bw(fill))),
                     type = "sankey",
                     family = "IBM Plex Sans",
                     size = 3, fill = "gray40", na.rm = TRUE) +
    theme_sankey(base_size = 18, base_family = "IBM Plex Sans") +
    theme(axis.title.x = element_blank()) +
    scale_x_discrete(labels = c("Official", "CDE revised")) +
    scale_fill_manual(values = c(`Full (100%)` = "darkgreen",
                                 `Partial (40%)` = "#009E73",
                                 `Negative (-100%)` = "#D55E00",
                                 `Negative (-40%)` = "#E69F00",
                                 `No tag` = "grey30",
                                 `Total\nspending` = "black",
                                 `Weighted\ncontribution` = "darkblue"),
                      name = NULL, guide = "none") +
    scale_colour_manual(values = c(`Full (100%)` = "darkgreen",
                                   `Partial (40%)` = "#009E73",
                                   `Negative (-100%)` = "#D55E00",
                                   `Negative (-40%)` = "#E69F00",
                                   `No tag` = "grey30",
                                   `Total\nspending` = "black",
                                   `Weighted\ncontribution` = "darkblue"),
                        name = NULL, guide = "none")
}
