
se <- read_xml("~/Downloads/SeznamProjektu.xml")

xml_ns(se)

se %>%
  xml_find_all("//d1:PRJ") %>%
  xml_find_all(".//d1:PRJSC")

md <- read_xml("~/Downloads/MatDat.xml")
xml_ns(md)

md %>%
  xml_find_all("//d1:SC") %>% as_list() %>%
  as_tibble_col() %>% unnest_wider("value") %>%
  select(ID, ID_OP, KOD, NAZEV) %>%
  map_dfr(unlist)
