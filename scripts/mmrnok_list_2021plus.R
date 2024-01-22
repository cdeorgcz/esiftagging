lapply(list.files("R", full.names = TRUE, recursive = TRUE), source)

lst_21 <- esif_list_tables(base_url = "https://dotaceeu.cz/cs/statistiky-a-analyzy/seznam-operaci-(prijemcu)")
tbl_21_url <- esif_get_table_entry(lst_21)$url

download.file(tbl_21_url, "data-input/ef_public_2127.xlsx")

dta_21 <- read_pubxls("data-input/ef_public_2127.xlsx")

dta_21_raw <- read_xlsx("data-input/ef_public_2127.xlsx", skip = 2)

dta_21_clnd <- dta_21_raw %>%
  slice(-1) %>%
  clean_names()

dta_21_clnd |>
  count(nazev_programu, cislo_programu)

dta_21_clnd |>
  filter(cislo_programu == "02") |>
  count(cislo_priority, nazev_priority,
        cislo_specifickeho_cile, nazev_specifickeho_cile,
        wt = as.numeric(celkove_naklady_na_operaci_czk)/1e9)

targets::tar_load(dt7_cz)
dt7_cz |>
  filter(str_detect(programme_title_short, "omenius")) |>
  count(priority_name, specific_objective_name)

dta_21_lng <- dta_21_clnd |>
  filter(str_detect(oblast_intervence_kod, "081|083"))

