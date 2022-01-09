make_tags_comparison <- function(efs_tagged_sum_prj, efs_mtagged_sum_prj) {
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

  return(sdf)
}
