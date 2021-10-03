# NB sestava PRV od MMR se načítá v sestavy.R

load_priority_list_prv <- function(prv_xlsx_path) {
  projektova <- readxl::read_excel(prv_xlsx_path,
                                   sheet = "Projektová opatření",
                                   skip = 0,
                                   col_types = "text") %>%
    janitor::clean_names() %>%
    mutate(prv_typ = "projektova")
  plosna <- readxl::read_excel(prv_xlsx_path,
                               skip = 0,
                               sheet = "Plošná opatření",
                               col_types = "text") %>%
    janitor::clean_names() %>%
    rename(id_operace = typ_operace) %>%
    mutate(prv_typ = "plosna")

  q <- dplyr::bind_rows(plosna, projektova)

  rename(q, prv_operace = id_operace) %>%
    separate(prv_operace, into = c("prv_operace_kod", "prv_operace_nazev"),
             sep = " ", extra = "merge") %>%
    select(starts_with("prv_operace"), starts_with("clanek"),
           opatreni, podopatreni, prv_typ) %>%
    drop_na(prv_operace_kod) %>%
    fill(starts_with("prv_operace"),
         starts_with("clanek"), ends_with("opatreni"), .direction = "down")
}

extract_agri_payments_year <- function(xml_path) {
  sxml <- read_xml(xml_path)


  rok <- str_extract(xml_path, "[0-9]{4}")

  # xml_ns(s20)

  # https://urbandatapalette.com/post/2021-03-xml-dataframe-r/

  sxml_platby_list <- sxml %>%
    xml_find_all(".//platba") %>%
    as_list()

  sxml_platby_tbl <- as_tibble_col(sxml_platby_list)

  sxml_platby_wide <- sxml_platby_tbl %>%
    unnest_wider("value")

  sxml_platby_flat <- sxml_platby_wide %>%
    unnest(everything()) %>%
    unnest(everything()) %>%
    mutate(across(matches("_(cr|eu|czk)$"), as.numeric)) %>%
    mutate(dt_rok = rok) %>%
    rename(fin_vyuct_czv = celkem_czk,
           fin_vyuct_narodni = zdroje_cr,
           fin_vyuct_eu = zdroje_eu) %>%
    mutate(eafrd_proj = str_detect(opatreni, "^[0-9]"),
           typ_podpory = case_when(str_detect(fond_typ_podpory, "SOT") ~ "Společná organizace trhu",
                                   str_detect(fond_typ_podpory, "PP") ~ "Přímá podpora",
                                   (eafrd_proj & str_detect(fond_typ_podpory, "EAFRD")) ~ "Projektová opatření",
                                   (!eafrd_proj & str_detect(fond_typ_podpory, "EAFRD")) ~ "Plošná opatření"),
           fond_typ_podpory = recode(fond_typ_podpory,
                                     `EAFRD` = "EAFRD 07-13",
                                     `EAFRD 14+` = "EAFRD 14-20",
                                     `EZZF PP` = "EZZF",
                                     `EZZF SOT` = "EZZF")) %>%
    select(-eafrd_proj) %>%
    rename(fond = fond_typ_podpory)

  return(sxml_platby_flat)
}

