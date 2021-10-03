process_reg_table_nonagri <- function(excel_path) {
  rc <- read_excel(excel_path) %>%
    set_names(c("area_category", "area_name", "climate_share"))

  rc %>%
    mutate(area_level3 = if_else(str_detect(area_category, "^[0-9]{1,3}$"),
                                 area_category, NA_character_) %>%
             str_pad(3, "left", "0"),
           area_level2 = if_else(str_detect(area_category, "^[A-Z][a-z]"),
                                 area_category, NA_character_),
           area_level1 = if_else(str_detect(area_category, "^[IVX]{1,4}\\."),
                                 area_category, NA_character_),
           area_climate_share = as.numeric(str_remove(climate_share, "\\s%"))/100,
           is_level2 = !is.na(area_level2)
           ) %>%
    fill(area_level1, .direction = "down") %>%
    group_by(area_level1) %>%
    mutate(area_level2_num = cumsum(is_level2),
           area_level1_fin = str_extract(area_level1, "^[IVX]{1,4}\\."),
           max_area_level2_num = max(area_level2_num),
           area_level2_num_fin = if_else(max_area_level2_num == 0,
                                         area_level2_num, area_level2_num)) %>%
    fill(area_level1_fin, area_level2_num_fin, area_level3, .direction = "down") %>%
    ungroup() %>%
    drop_na(area_name) %>%
    mutate(area_code = paste0(area_level1_fin, area_level2_num_fin, ".", area_level3)) %>%
    select(oblast_intervence_nazev_en = area_name,
           oblast_intervence_kod = area_code,
           climate_share = area_climate_share)
}

read_reg_table_agri <- function(excel_path, excel_sheet) {
  rc <- read_excel(excel_path, excel_sheet)
  return(rc)
}
