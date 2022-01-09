targets::tar_load(esif_mtagged_sum)
targets::tar_load(esif_tagged_sum)


targets::tar_load(efs_tagged_sum_prj)
targets::tar_load(efs_mtagged_sum_prj)

sdf <- left_join(efs_tagged_sum_prj,
                 efs_mtagged_sum_prj) |>
  group_by(across(starts_with("climate_share"))) |>
  summarise(across(starts_with("fin_"), sum, na.rm = TRUE), .groups = "drop") |>
  drop_na(climate_share) |>
  mutate(climate_share = case_when(climate_share == 0 ~ "No tag",
                                   climate_share == 0.4 ~ "Partial (40%)",
                                   climate_share == 1 ~ "Full (100%)",
                                   climate_share == -0.4 ~ "Negative (-40%)",
                                   climate_share == -1 ~ "Negative (-100%)",
                                   is.na(climate_share) ~ "Unknown") %>%
           fct_relevel("No tag", "Partial (40%)", "Full (100%)",
                       "Negative (-40%)", "Negative (-100%)") %>% fct_rev(),
         climate_share_m = case_when(climate_share_m == 0 ~ "No tag",
                                     climate_share_m == 0.4 ~ "Partial (40%)",
                                     climate_share_m == 1 ~ "Full (100%)",
                                     climate_share_m == -0.4 ~ "Negative (-40%)",
                                     climate_share_m == -1 ~ "Negative (-100%)",
                                     is.na(climate_share_m) ~ "Unknown") %>%
           fct_relevel("No tag", "Partial (40%)", "Full (100%)",
                       "Negative (-40%)", "Negative (-100%)") %>% fct_rev())

library(ggalluvial)

ggplot(data = sdf,
       aes(axis1 = climate_share, axis2 = climate_share_m, y = fin_vyuct_czv/1e9)) +
  scale_x_discrete(limits = c("Class", "Sex"), expand = c(.2, .05)) +
  geom_alluvium(aes(fill = climate_share_m, colour = climate_share_m)) +
  geom_stratum(fill = "lightgrey", colour = "white") +
  geom_text(stat = "stratum", aes(label = after_stat(stratum))) +
  scale_fill_manual(values = c(`Full (100%)` = "darkgreen",
                               `Partial (40%)` = "lightgreen",
                               `Negative (-100%)` = "darkred",
                               `Negative (-40%)` = "orange",
                               None = "darkgrey",
                               `Total\nspending` = "black",
                               `Weighted\ncontribution` = "darkblue"),
                    name = NULL, guide = "none") +
  scale_colour_manual(values = c(`Full (100%)` = "darkgreen",
                                 `Partial (40%)` = "lightgreen",
                                 `Negative (-100%)` = "darkred",
                                 `Negative (-40%)` = "orange",
                                 None = "darkgrey",
                                 `Total\nspending` = "black",
                                 `Weighted\ncontribution` = "darkblue"),
                      name = NULL, guide = "none") +
  theme_minimal()


