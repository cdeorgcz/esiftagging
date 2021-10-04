library(targets)
library(tarchetypes)
library(future)

# Config ------------------------------------------------------------------

# Set target-specific options such as packages.
tar_option_set(packages = c("dplyr", "here", "readxl",
                            "janitor", "curl", "httr", "stringr", "config",
                            "dplyr", "future", "arrow", "tidyr",
                            "ragg", "magrittr", "czso", "lubridate", "writexl",
                            "readr", "purrr", "pointblank", "tarchetypes",
                            "details", "forcats", "ggplot2",
                            "xml2", "tibble", "ptrr", "DT", "plotly",
                            "summarywidget", "htmltools", "crosstalk"),
               # debug = "compiled_macro_sum_quarterly",
               # imports = c("purrrow"),
)

options(crayon.enabled = TRUE,
        scipen = 100,
        statnipokladna.dest_dir = "sp_data",
        czso.dest_dir = "~/czso_data",
        yaml.eval.expr = TRUE)

future::plan(multisession)

source("R/utils.R")
source("R/functions.R")

cnf <- config::get(config = "default")
names(cnf) <- paste0("c_", names(cnf))
list2env(cnf, envir = .GlobalEnv)

# tar_renv(path = "packages.R")

## Geo helpers -------------------------------------------------------------

t_geo_helpers <- list(
  # vazby ZÚJ a obcí, abychom mohli ZÚJ v datech
  # převést na obce
  tar_target(zuj_obec, get_zuj_obec()),
  # číselník krajů pro vložení kódu kraje v PRV
  tar_target(cis_kraj, czso::czso_get_codelist("cis100")),
  # populace obcí pro vážení projektů mezi kraji
  tar_target(pop_obce, get_stats_pop_obce(c_czso_pop_table_id))
)


# ESIF data ---------------------------------------------------------------

## PRV list of priorities

t_prv_priorities <- list(
  tar_target(prv_priorities, load_priority_list_prv(c_priority_prv_xls))
)

t_agri_opendata <- list(
  tar_target(agri_opendata_urls, c_agri_opendata_urls),
  tar_target(agri_opendata_paths, file.path(c_agri_opendata_dir,
                                            c_agri_opendata_zipxml)),
  tar_target(agri_opendata_zipfiles,
             {download.file(agri_opendata_urls,
                            agri_opendata_paths,
                            method = "libcurl")
               agri_opendata_paths
             }, format = "file", pattern = map(agri_opendata_urls,
                                               agri_opendata_paths)),
  tar_target(agri_opendata,
             extract_agri_payments_year(agri_opendata_zipfiles),
             pattern = map(agri_opendata_zipfiles))
)

## Public project data -----------------------------------------------------

t_public_list <- list(
  tar_download(ef_pubxls, c_ef_pubxls_url,
               here::here("data-input/ef_publish.xls")),
  tar_target(ef_pub, read_pubxls(ef_pubxls))
)

## Custom MS sestavy -------------------------------------------------------

t_sestavy <- list(
  # finanční pokrok
  tar_target(efs_fin, load_efs_fin(c_sest_dir, c_sest_xlsx_fin)),
  # seznam ŽOPek
  tar_target(efs_zop, load_efs_zop(c_sest_dir, c_sest_xlsx_zop)),
  # základní info o projektech
  # obsahuje ekonomické kategorie intervence, SC atd.
  tar_target(efs_prj, load_efs_prj(c_sest_dir, c_sest_xlsx_prj)),
  # oblasti intervence
  tar_target(efs_obl, load_efs_obl(c_sest_dir, c_sest_xlsx_obl)),
  # výřes základních informací o projektech
  tar_target(efs_prj_basic, efs_prj %>% select(-starts_with("katekon_"),
                                               -starts_with("sc_")) %>%
               distinct()),
  # specifické cíle
  # bez rozpadu na kategorie intervence
  # protože ten je v datech nepřiznaný
  tar_target(efs_prj_sc, efs_prj %>%
               select(prj_id, starts_with("sc_")) %>%
               distinct()),
  # kategorie intervence, bez rozpadu na SC
  tar_target(efs_prj_kat, efs_prj %>%
               select(prj_id, starts_with("katekon_")) %>%
               distinct() %>%
               group_by(prj_id) %>%
               mutate(katekon_podil = 1/n())),
  # sečíst ŽOP za každý projekt po letech
  tar_target(efs_zop_annual, summarise_zop(efs_zop, quarterly = FALSE)),
  # a po čtvrtletích
  tar_target(efs_zop_quarterly, summarise_zop(efs_zop, quarterly = TRUE)),
  # načíst PRV
  tar_target(efs_prv, load_prv(c_prv_data_path, cis_kraj)),
  # posčítat platby PRV za projekt po letech
  tar_target(efs_prv_annual, summarise_prv(efs_prv, quarterly = FALSE)),
  # a PRV po čtvrtletích
  tar_target(efs_prv_quarterly, summarise_prv(efs_prv, quarterly = TRUE))
)

## Compile  ----------------------------------------------------------------

t_esif_compile <- list(
  # rozpadnout na všechny známé kategorie
  tar_target(efs_compiled, efs_compile(efs_prj_kat, efs_obl, efs_prj_sc)),
  # přidat platby po kvartálech
  tar_target(efs_compiled_fin,
             efs_add_financials(efs_compiled, efs_zop_quarterly)),
  # spojit PRV a ostatní, sečíst po letech, bez regionu
  tar_target(sum_annual,
             esif_summarise(efs_compiled_fin,
                            efs_prv_annual,
                            quarterly = FALSE, regional = FALSE)),
  # spojit PRV a ostatní, sečíst po kvartálech, bez regionu
  tar_target(sum_quarterly,
             esif_summarise(efs_compiled_fin,
                            efs_prv_quarterly,
                            quarterly = TRUE, regional = FALSE))
)

## Compile by OP -----------------------------------------------------------

t_op_compile <- list(
  tar_target(compiled_op_sum,
             summarise_by_op(efs_zop_quarterly, efs_prv_quarterly)))


## Load climate categorisations --------------------------------------------

### From regulation --------------------------------------------------------

t_climacat_reg <- list(
  tar_file(reg_table_nonagri_xlsx, c_reg_table_nonagri_xlsx),
  tar_target(reg_table_nonagri,
             process_reg_table_nonagri(reg_table_nonagri_xlsx)),
  tar_file(reg_table_agri_xlsx, c_reg_table_agri_xlsx),
  tar_target(reg_table_agri,
             read_reg_table_agri(reg_table_agri_xlsx,
                                 c_reg_table_agri_sheetname))
)


## Integrate climate tag ---------------------------------------------------

t_climate_tag <- list(
  tar_target(efs_tagged, left_join(efs_compiled_fin, reg_table_nonagri,
                                   by = "oblast_intervence_kod")),
  tar_target(agri_tagged, tag_agri(agri_opendata, reg_table_agri))
)


## Export summaries of tagged data --------------------------------------------

t_export <- list(
  tar_file(export_all_ops_xlsx,
           export_table(esif_tagged_sum,
                        here::here(c_export_dir, c_export_all_ops_xlsx),
                        write_xlsx)),
  tar_file(export_prv_detail_xlsx,
           export_table(prv_tagged_sum,
                        here::here(c_export_dir, c_export_prv_detail_xlsx),
                        write_xlsx)),
  tar_file(export_agri_detail_xlsx,
           export_table(agri_tagged_sum,
                        here::here(c_export_dir, c_export_agri_detail_xlsx),
                        write_xlsx)),
  tar_file(export_nonagri_detail_xlsx,
           export_table(efs_tagged_sum_op_sc,
                        here::here(c_export_dir, c_export_nonagri_detail_xlsx),
                        write_xlsx)),
  tar_file(export_nonagri_projekty_xlsx,
           export_table(efs_tagged_sum_prj,
                        here::here(c_export_dir, c_export_nonagri_projekty_xlsx),
                        write_xlsx)),
  tar_file(export_all_ops_csv,
           export_table(esif_tagged_sum,
                        here::here(c_export_dir, c_export_all_ops_csv),
                        write_excel_csv2)),
  tar_file(export_prv_detail_csv,
           export_table(prv_tagged_sum,
                        here::here(c_export_dir, c_export_prv_detail_csv),
                        write_excel_csv2)),
  tar_file(export_agri_detail_csv,
           export_table(agri_tagged_sum,
                        here::here(c_export_dir, c_export_agri_detail_csv),
                        write_excel_csv2)),
  tar_file(export_nonagri_detail_csv,
           export_table(efs_tagged_sum_op_sc,
                        here::here(c_export_dir, c_export_nonagri_detail_csv),
                        write_excel_csv2)),
  tar_file(export_nonagri_projekty_csv,
           export_table(efs_tagged_sum_prj,
                        here::here(c_export_dir, c_export_nonagri_projekty_csv),
                        write_excel_csv2))
)


t_tagged_summarised <- list(
  tar_target(efs_tagged_sum_prj,
             summarise_tagged(efs_tagged %>% add_op_labels(),
                              prj_id, sc_id, sc_nazev, op_zkr) %>%
               left_join(efs_prj %>% distinct(prj_id, prj_nazev), by = "prj_id")),
  tar_target(efs_tagged_sum_kat,
             summarise_tagged(efs_tagged)),
  tar_target(efs_tagged_sum_op_sc,
             summarise_tagged(efs_tagged %>% add_op_labels(),
                              sc_id, sc_nazev, op_zkr)),
  tar_target(efs_tagged_sum_op,
             summarise_tagged(efs_tagged %>% add_op_labels(),
                              op_zkr)),
  tar_target(prv_tagged, subset_prv_tagged(agri_tagged)),
  tar_target(prv_tagged_sum, summarise_prv_tagged(prv_tagged)),
  tar_target(agri_tagged_sum, summarise_agri_tagged(agri_tagged))

)


## Summarise and compile tagged data ---------------------------------------

t_tagged_compiled <- list(
  tar_target(esif_tagged_sum, summarise_tagged_op_only(efs_tagged_sum_op_sc, prv_tagged_sum))
)

## Plots of main outputs

t_tagged_plots <- list(
  tar_target(plot_tagged_agri, make_plot_tagged_agri(agri_tagged)),
  tar_target(plot_tagged_all, make_plot_tagged_all(esif_tagged_sum))
)


## Overview for manual tagging ----------------------------------------------

t_tagging_aid <- list(
  tar_target(efs_tagged_for_plot,
             prep_tagged_for_plot(efs_tagged_sum_op_sc)),
  tar_target(efs_plotly, make_efs_plotly(efs_tagged_for_plot)),
  tar_target(agri_plotly, make_agri_plotly(agri_tagged)),
  tar_file(export_for_tagging,
           writexl::write_xlsx(list(
             sumar = esif_tagged_sum,
             prv_detail = prv_tagged_sum,
             agri_detail = agri_tagged_sum,
             nonagri_detail = efs_tagged_sum_op_sc,
             nonagri_projekty = efs_tagged_sum_prj
           ),
           c_export_tagging_xlsx))
)

## Validation and exploration ----------------------------------------------

t_valid_zop_timing <- list(
  tar_target(zop_timing_df, build_efs_timing(efs_prj, efs_zop, ef_pub)),
  tar_target(zop_timing_plot, make_zop_timing_plot(zop_timing_df))
)


## Build and export codebook -----------------------------------------------

t_codebook <- list(
  tar_target(sum_codebook,
             make_codebook(sum_quarterly)),
  tar_file(sum_codebook_yaml,
           {pointblank::yaml_write(informant = sum_codebook %>%
                                     pointblank::set_read_fn(read_fn = ~sum_quarterly),
                                   path = c_export_dir,
                                   filename = c_export_cdbk)
             file.path(c_export_dir, c_export_cdbk)
           })
)

# HTML output -------------------------------------------------------------

source("R/html_output.R")


# Compile targets lists ---------------------------------------------------

list(t_public_list, t_prv_priorities, t_geo_helpers, t_sestavy, t_op_compile, t_valid_zop_timing,
     t_esif_compile, t_export, t_codebook, t_html, t_agri_opendata,
     t_climacat_reg, t_climate_tag, t_tagged_summarised, t_tagging_aid,
     t_tagged_compiled, t_tagged_plots)
