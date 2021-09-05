make_codebook <- function(compiled_macro_sum_quarterly) {
  create_informant(tbl = compiled_macro_sum_quarterly,
                   label = "Codebook hlavního výstupu") %>%
    info_tabular(Info = "Tabulka se součty výdajů podle času, kraje, kategorie QUEST/HERMIN, TC DoP a cíle EU2020",
                 Note = "Platí pro data po kvartálech a analogicky i pro roční data",
                 `Celková struktura` = "dlouhý formát: čas a kraj jsou v řádcích, metadata a jednotlivé zdroje financí jsou ve sloupcích",
                 `Názvy proměnných` = "platí i pro ostatní datové sady v pipeline:\n- `dt_`: proměnné časového určení\n- `fin_`: finanční údaje") %>%    info_columns("source",
                 Popis = "Zdroj dat (MSSF/MSEU nebo SZIF (PRV))") %>%
    info_columns("dt_zop_rok",
                 Popis = "Rok proplacení ŽOP",
                 `Zdroj dat` = "Datum proplacení ŽOP") %>%
    info_columns("dt_zop_kvartal",
                 Popis = "Kvartál proplacení ŽOP",
                 `Zdroj dat` = "Datum proplacení ŽOP") %>%
    info_columns("dt_zop_kvartal_datum",
                 Popis = "První den kvartálu",
                 `Zdroj dat` = "Datum proplacení ŽOP") %>%
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
