get_stats_pop_obce <- function(czso_pop_table_id) {
  pop_all <- czso::czso_get_table(czso_pop_table_id)

  pop_all %>%
    filter(is.na(pohlavi_kod), vuzemi_cis == "43", rok >= 2014) %>%
    # select(hodnota, rok, geo_id = vuzemi_kod)
    select(hodnota, rok, obec_id = vuzemi_kod) %>%
    group_by(obec_id) %>%
    summarise(pocob_stred201420 = mean(hodnota))
}

get_zuj_obec <- function() {
  czso::czso_get_codelist("cis43vaz51") %>%
    select(geo_id = CHODNOTA2, obec_id = CHODNOTA1)
}
