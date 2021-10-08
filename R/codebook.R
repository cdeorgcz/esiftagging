make_codebook <- function(esif_tagged_sum_op) {
  create_informant(tbl = esif_tagged_sum_op,
                   label = "Codebook hlavního výstupu") %>%
    info_tabular(Info = "Tabulka se součty výdajů podle OP, klima tagu a kategorie určující klimatag",
                 Rozsah = "Z CAP/SZP zahruje jen PRV - projektová i plošná opatření",
                 Proměnné = "kategorie určující klimatag je u PRV opatření, u ostatních OP je to oblast intervencí",
                 Detail = "Codebook obsahuje všechny proměnné obsažené v různých exportech",
                 `Celková struktura` = "dlouhý formát: kategorie jsou v řádcích, metadata a jednotlivé zdroje financí jsou ve sloupcích",
                 `Názvy proměnných` = "platí i pro ostatní datové sady v pipeline:\n- `dt_`: proměnné časového určení\n- `fin_`: finanční údaje") %>%
    info_columns(starts_with("prv_opatreni"),
                 Typ = "Opatření PRV/CAP",
                 Note = "Existuje jen u výdajů CAP") %>%
    info_columns(starts_with("oblast_intervence"),
                 Typ = "Oblast intervence (area of intervention)",
                 Note = "Nexistuje u výdajů CAP - zde jen nařízení",
                 Detail = "Kategorie určená v nařízení, na niž jsou v prováděcím nařízení navázány klima tagy") %>%
    info_columns(starts_with("climate_share"),
                 Popis = "Podíl přispění ke klimatu - podle prováděcího nařízení EK") %>%
    info_columns(starts_with("sc_"),
                 Typ = "Identifikace specifického cíle podle OP") %>%
    info_columns(starts_with("op_zkr"),
                 Popis = "Česká zkratka operačního programu") %>%
    info_columns(starts_with("fond"),
                 Popis = "Fond CAP") %>%
    info_columns(starts_with("typ_podpory"),
                 Popis = "Typ podpory CAP") %>%
    info_columns(starts_with("prj_id"),
                 Popis = "Kód projektu") %>%
    info_columns(starts_with("prj_"),
                 Typ = "Informace o projektu. Nedostupné u PRV") %>%
    info_columns(starts_with("dt_"), Typ = "Časový údaj (datum)") %>%
    info_columns(starts_with("fin_"), Typ = "Finance",
                 Jednotka = "CZK",
                 `Zdroj dat` = "ŽOP sečtené podle data proplacení") %>%
    info_columns(contains("_czv"), `Zdroj financí` = "Celkové způsobilé výdaje") %>%
    info_columns(contains("_eu"), `Zdroj financí` = "Příspěvek Unie") %>%
    info_columns(contains("_sr"), `Zdroj financí` = "Státní rozpočet") %>%
    info_columns(contains("_sf"), `Zdroj financí` = "Státní fondy") %>%
    info_columns(contains("_obec"), `Zdroj financí` = "Obec") %>%
    info_columns(contains("_kraj"), `Zdroj financí` = "Kraj") %>%
    info_columns(contains("_soukr"), `Zdroj financí` = "Soukromý") %>%
    info_columns(contains("_jine_nar"), `Zdroj financí` = "Soukromý") %>%
    info_columns(contains("_narodni"),
                 `Zdroj financí` = "Národní")
  }
