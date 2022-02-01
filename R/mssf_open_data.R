
extract_sc_codelist <- function(od_metadata_xml) {
  md <- read_xml(od_metadata_xml)
  md %>%
    xml_find_all("//d1:SC") %>% as_list() %>%
    as_tibble_col() %>% unnest_wider("value") %>%
    select(ID, ID_OP, KOD, NAZEV) %>%
    map_dfr(unlist)
}

extract_prj_list <- function(od_data_xml) {
  se <- read_xml(od_data_xml)
  se %>%
    xml_find_all("//d1:PRJ") |> as_list()
}

extract_prj_sc <- function(od_prj_list, od_sc_codelist) {
  map_dfr(od_prj_list, ~list(prj_id = .x[["KOD"]][[1]],
                             sc = .x[names(.x) == "PRJSC"] |>
                               map(`[[`, 1))) |>
    mutate(sc_xid = unlist(sc)) |>
    select(prj_id, sc_xid) |>
    left_join(od_sc_codelist, by = c(sc_xid = "ID")) |>
    select(prj_id, sc_id = KOD, sc_nazev = NAZEV)
}
