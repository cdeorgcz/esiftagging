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
