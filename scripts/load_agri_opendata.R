library(xml2)
library(tidyverse)
library(future)

read_xml("~/Downloads/Seznam_prijemcu_dotaci_za_rok_2017.zip")

extract_prv_payments_year <- function(xml_path) {
  sxml <- read_xml(xml_path)

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
    mutate(across(matches("_(cr|eu|czk)$"), as.numeric))

  return(sxml_platby_flat)
}

s20_platby_flat <- extract_prv_payments_year("~/Downloads/spd_2020.xml")
s17_platby_flat <- extract_prv_payments_year("~/Downloads/spd_2017.xml")

spl <-

s20_platby_flat %>%
  count(fond_typ_podpory, opatreni, wt = zdroje_eu/1e9, sort = T) %>%
  mutate(total = cumsum(n),
         share = n/sum(n),
         share_cum = cumsum(share)) %>%
  View()

s20_platby_flat %>%
  count(fond_typ_podpory, wt = celkem_czk/1e9)

s20_platby_flat %>%
  filter(fond_typ_podpory == "EAFRD 14+") %>%
  filter(str_detect(opatreni, "^[0-9]")) %>%
  count(wt = celkem_czk/1e9, sort = T)

s20_platby_flat %>%
  filter(fond_typ_podpory == "EAFRD 14+") %>%
  # filter(str_detect(opatreni, "^[0-9]")) %>%
  count(opatreni, wt = celkem_czk/1e9, sort = T) %>%
  View()

sum(s20_platby_flat$celkem_czk/1e9, na.rm = T)

efs_prv %>%
  count(year(dt_platba), wt = fin_vyuct_czv/1e9)

efs_prv %>%
  count(priorita, prioritni_oblast, opatreni, operace,
        prv_operace_kod,
        # investicni_zamer,
        wt = fin_vyuct_czv) %>%
  View()

efs_prv %>%
  count(opatreni, operace,
        prv_operace_kod, investicni_zamer, wt = fin_vyuct_czv) %>%
  View()
