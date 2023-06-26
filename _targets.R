
library(targets)
library(tarchetypes)
library(future)

options(conflicts.policy = list(warn = FALSE))
options(clustermq.scheduler = "LOCAL")
options(timeout = 120) # for MMR open data file, which takes long to download

# Config ------------------------------------------------------------------

# Set target-specific options such as packages.
tar_option_set(packages = c("dplyr", "here", "readxl", "readr",
                            "janitor", "curl", "httr", "stringr", "config",
                            "dplyr", "future", "arrow", "tidyr",
                            "ragg", "magrittr", "czso", "lubridate", "writexl",
                            "readr", "purrr", "tarchetypes",
                            "pointblank", "rvest", "svglite", "downloadthis",
                            "details", "forcats", "ggplot2",
                            "xml2", "tibble", "ptrr", "DT", "plotly",
                            "summarywidget", "htmltools", "crosstalk",
                            "ggsankey", "coloratio", "widyr", "tidytext",
                            "jsonlite", "ggraph", "igraph", "topicmodels")
               # debug = "compiled_macro_sum_quarterly",
               # imports = c("purrrow"),
)

options(crayon.enabled = TRUE,
        scipen = 100,
        statnipokladna.dest_dir = "sp_data",
        czso.dest_dir = "~/czso_data",
        yaml.eval.expr = TRUE)

future::plan(multisession)

lapply(list.files("R", full.names = TRUE, recursive = TRUE), source)

cnf <- config::get(config = "default")
names(cnf) <- paste0("c_", names(cnf))
list2env(cnf, envir = .GlobalEnv)

# tar_renv()

# ESIF data ---------------------------------------------------------------

## PRV list of priorities -------------------------------------------------

t_prv_priorities <- list(
  tar_target(prv_priorities, load_priority_list_prv(c_priority_prv_xls))
)

## PRV open data -------------------------------------------------

t_agri_opendata <- list(

  # map over URLs and years in config.yml
  #

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


## MS open data ---------------------------------------------------------------
t_opendata <- list(

  # public open data in XML - download data and open data and load

  tar_download(od_meta_xml, c_ef_open_metadata_url, c_ef_open_metadata_path,
               cue = tar_cue(mode = if(c_refresh_open_metadata) "thorough" else "never")),
  tar_download(od_data_xml, c_ef_open_data_url, c_ef_open_data_path,
               cue = tar_cue(mode = if(c_refresh_open_data) "thorough" else "never")),
  # tar_file(od_meta_xml, c_ef_open_metadata_path),
  # tar_file(od_data_xml, c_ef_open_data_path),
  tar_target(od_prj_list, extract_prj_list(od_data_xml)),
  tar_target(od_sc_codelist, extract_sc_codelist(od_meta_xml)),
  tar_target(od_prj_sc, extract_prj_sc(od_prj_list, od_sc_codelist))
)

## Public project data -----------------------------------------------------

t_public_list <- list(
  tar_age(ef_source,
             if(is.null(c_ef_pubxls_url)) {
               esif_get_table_entry()
             } else {date_from_url(c_ef_pubxls_url)},
          age = as.difftime(30, units = "days")),
  tar_target(ef_url, ef_source |> pull(url), format = "url"),
  tar_file(ef_pubxls,
           curl::curl_download(ef_url, here::here("data-input/ef_public.xlsx"))),
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
  tar_target(efs_zop_quarterly, summarise_zop(efs_zop, quarterly = TRUE))
)


## EC data -----------------------------------------------------------


### 2021+ ----------------------------------------------------------------

t_ec <- list(
  tar_target(ec_fin_21_plan,
             get_cohdata("hgyj-gyin", `$query` =
                         "SELECT *
                         where dimension_type == 'Intervention Field'
                         LIMIT 100000")

  )
)

## Compile  ----------------------------------------------------------------

t_esif_compile <- list(
  # rozpadnout na všechny známé kategorie
  tar_target(efs_compiled, efs_compile(efs_prj_kat, efs_obl, efs_prj_sc)),
  # přidat platby po kvartálech
  tar_target(efs_compiled_fin,
             efs_add_financials(efs_compiled, efs_zop_quarterly))
)

t_esif_compile_withopendata <- list(
  tar_target(ef_compiled_fin,
             compile_from_od(ef_pub, efs_obl, efs_prj_sc, od_prj_sc))
)

t_switch <- list(
  if (c_use_public_data) {
    tar_target(data_for_tagging, ef_compiled_fin)
  }  else {
    tar_target(data_for_tagging, efs_compiled_fin)
  }
)

# Climate categorisations --------------------------------------------

## From regulation --------------------------------------------------------

t_climacat_reg <- list(
  tar_file(reg_table_nonagri_xlsx, c_reg_table_nonagri_xlsx),
  tar_target(reg_table_nonagri,
             process_reg_table_nonagri(reg_table_nonagri_xlsx)),
  tar_file(reg_table_agri_xlsx, c_reg_table_agri_xlsx),
  tar_target(reg_table_agri,
             read_reg_table_agri(reg_table_agri_xlsx,
                                 c_reg_table_agri_sheetname))
)

t_hier <- list(
  tarchetypes::tar_file_read(cile_dop_a_sc, c_hier_xlsx,
                             read_excel(path = !!.x, sheet = "SC", skip = 2) |>
                               select(tc_id = TC, sc_id = `spec cil kod`) |>
                               drop_na() |>
                               distinct())
)

## Manual -----------------------------------------------------------------

t_climacat_manual <- list(
  tar_file(tags_manual_xlsx, c_tags_manual_xlsx),
  tar_target(tags_manual,
             read_excel(tags_manual_xlsx, c_tags_manual_sheetname) |>
               select(oblast_intervence_kod, sc_id,
                      oblast_intervence_nazev_en,
                      climate_share_m = `ZÁVĚR KONTROLY (TAG)`)
  )
)


# Integrate climate tag ---------------------------------------------------

t_climate_tag <- list(
  tar_target(efs_tagged, tag_efs(data_for_tagging, reg_table_nonagri, cile_dop_a_sc, retag = FALSE)),
  tar_target(efs_mtagged, tag_efs(data_for_tagging, tags_manual, cile_dop_a_sc, retag = TRUE)),
  tar_target(agri_tagged, tag_agri(agri_opendata, reg_table_agri))
)


# Summarise and compile tagged data ---------------------------------------

t_tagged_summarised <- list(
  tar_target(efs_tagged_sum_prj,
             summarise_tagged(efs_tagged %>% add_op_labels(),
                              prj_id, sc_id, sc_nazev, op_zkr, op_id) %>%
               left_join(efs_prj %>% distinct(prj_id, prj_nazev,
                                              vyzva_id, vyzva_nazev),
                         by = "prj_id") %>%
               left_join(ef_pub %>% distinct(prj_id, prj_shrnuti,
                                             p_ic, p_forma, p_nazev),
                         by = "prj_id")),
  tar_target(efs_tagged_sum_kat,
             summarise_tagged(efs_tagged)),
  tar_target(efs_tagged_sum_op_sc,
             summarise_tagged(efs_tagged %>% add_op_labels(),
                              sc_id, sc_nazev, op_zkr, op_id)),
  tar_target(efs_tagged_sum_op,
             summarise_tagged(efs_tagged %>% add_op_labels(),
                              op_zkr, op_id)),
  tar_target(efs_tagged_sum_rule,
             summarise_tagged(efs_tagged %>% add_op_labels(),
                              op_zkr, to_rule, sc_id, sc_nazev, tc_id, oblast_intervence_kod)),
  tar_target(esif_tagged_sum_op, bind_rows(efs_tagged_sum_op, prv_tagged_sum)),
  tar_target(prv_tagged, subset_prv_tagged(agri_tagged)),
  tar_target(prv_tagged_sum, summarise_prv_tagged(prv_tagged)),
  tar_target(agri_tagged_sum, summarise_agri_tagged(agri_tagged))

)

t_mtagged_summarised <- list(
  tar_target(efs_mtagged_sum_prj,
             summarise_tagged(efs_mtagged %>% add_op_labels(),
                              prj_id, sc_id, sc_nazev, op_zkr, op_id,
                              tag_var = climate_share_m) %>%
               left_join(efs_prj %>% distinct(prj_id, prj_nazev,
                                              vyzva_id, vyzva_nazev),
                         by = "prj_id") %>%
               left_join(ef_pub %>% distinct(prj_id, prj_shrnuti,
                                             p_ic, p_forma, p_nazev),
                         by = "prj_id")),
  tar_target(efs_mtagged_sum_kat,
             summarise_tagged(efs_mtagged,
                              tag_var = climate_share_m)),
  tar_target(efs_mtagged_sum_op_sc,
             summarise_tagged(efs_mtagged %>% add_op_labels(),
                              sc_id, sc_nazev, op_zkr, op_id,
                              tag_var = climate_share_m)),
  tar_target(efs_mtagged_sum_op,
             summarise_tagged(efs_mtagged %>% add_op_labels(),
                              op_zkr, op_id,
                              tag_var = climate_share_m)),
  tar_target(esif_mtagged_sum_op, bind_rows(efs_mtagged_sum_op, prv_tagged_sum)),
  tar_target(efs_tags_compare, make_tags_comparison(efs_tagged_sum_prj,
                                                    efs_mtagged_sum_prj))
)


t_tagged_compiled <- list(
  tar_target(esif_tagged_sum,
             summarise_tagged_op_only(efs_tagged_sum_op_sc, prv_tagged_sum)),
  tar_target(esif_mtagged_sum,
             summarise_tagged_op_only(efs_mtagged_sum_op_sc, prv_tagged_sum,
                                      tag_var = climate_share_m))
)

# Plots of main outputs ---------------------------------------------------

t_tagged_plots <- list(
  tar_target(plot_tagged_agri, make_plot_tagged_agri(agri_tagged)),
  tar_target(plot_tagged_op, make_plot_tagged_all(esif_tagged_sum)),
  tar_target(plot_tagged_op_m, make_plot_tagged_all(esif_mtagged_sum,
                                                      tag_var = climate_share_m,
                                                    tag_type = "revised")),
  tar_target(plot_all_data, prep_plot_all_data(efs_tagged_sum_op_sc,
                                               tag_var = climate_share)),
  tar_target(plot_all_data_with_agri, prep_plot_all_data(esif_tagged_sum,
                                               tag_var = climate_share)),
  tar_target(plot_all_data_m, prep_plot_all_data(efs_mtagged_sum_op_sc,
                                                 tag_var = climate_share_m)),
  tar_target(plot_all_with_agri, make_plot_all(plot_all_data_with_agri)),
  tar_target(plot_all, make_plot_all(plot_all_data, agri = FALSE)),
  tar_target(plot_all_m, make_plot_all(plot_all_data_m, tag_type = "revised", agri = FALSE)),
  tar_target(plot_comparison,
             make_comparison_plot(plot_all_data, plot_all_data_m)),
  tar_target(plot_weighted_op, make_plot_weighted_all(esif_tagged_sum,)),
  tar_target(plot_weighted_op_m, make_plot_weighted_all(esif_mtagged_sum,
                                                        tag_var = climate_share_m,
                                                        tag_type = "revised")),
  tar_target(plot_sankey, make_tag_sankey(efs_tags_compare)),
  tar_target(plot_retag_decomposition, make_plot_retag_decomposition(prj_retagged)),
  tar_target(plot_retag_decomposition_rough, make_plot_retag_decomposition_rough(prj_retagged))
)

# Overview for manual tagging ----------------------------------------------

t_tagging_aid <- list(
  tar_target(efs_tagged_for_plot,
             prep_tagged_for_plot(efs_tagged_sum_op_sc)),
  tar_target(efs_plotly, make_efs_plotly(efs_tagged_for_plot)),
  tar_target(agri_plotly, make_agri_plotly(agri_tagged)),
  tar_file(export_for_tagging,
           writexl::write_xlsx(list(
             sumar = esif_tagged_sum,
             esif_detail = esif_tagged_sum_op,
             prv_detail = prv_tagged_sum,
             agri_detail = agri_tagged_sum,
             nonagri_detail = efs_tagged_sum_op_sc,
             nonagri_projekty = efs_tagged_sum_prj
           ),
           c_export_tagging_xlsx))
)


# Sample projects which were retagged -------------------------------------

t_sample <- list(
  tar_target(prj_tagcomparison, make_prj_comparison(efs_tagged, efs_mtagged)),
  tar_target(prj_retagged, get_retagged_prj(prj_tagcomparison, ef_pub)),
  tar_target(prj_retagged_sample, sample_retagged(prj_retagged))
)

# Export summaries of tagged data --------------------------------------------

t_export <- list(
  tar_file(export_all_ops_xlsx,
           export_table(esif_tagged_sum,
                        here::here(c_export_dir, c_export_all_ops_xlsx),
                        write_xlsx)),
  tar_file(export_all_ops_detail_xlsx,
           export_table(esif_tagged_sum_op,
                        here::here(c_export_dir, c_export_all_ops_detail_xlsx),
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
  tar_file(export_all_ops_detail_csv,
           export_table(esif_tagged_sum_op,
                        here::here(c_export_dir, c_export_all_ops_detail_csv),
                        write_csv)),
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
  tar_file(export_nonagri_projekty_parquet,
           export_table(efs_tagged_sum_prj,
                        here::here(c_export_dir, c_export_nonagri_projekty_parquet),
                        write_parquet))
)


# Validation and exploration ----------------------------------------------

## Text analysis teplárenství ---------------------------------------------

t_text_teplarny <- list(
  tar_url(stopwords_cz_url, "https://raw.githubusercontent.com/stopwords-iso/stopwords-cs/master/stopwords-cs.txt"),
  tar_target(stopwords_cz, read_lines(stopwords_cz_url)),
  tar_target(stopwords_all_cz, c(stopwords_cz, noise_cz, stopwords_cz_additional)),
  tar_target(tepl_texts, get_prj_texts(efs_tagged_sum_prj, sc_id == "01.3.15.3.5")),
  tar_target(tepl_lem_title, lemmatize_esif(efs_tagged_sum_prj, prj_nazev, .sample = NULL,
                                            sc_id == "01.3.15.3.5")),
  tar_target(tepl_lem_descr, lemmatize_esif(efs_tagged_sum_prj, prj_shrnuti, .sample = NULL,
                                            sc_id == "01.3.15.3.5")),
  tar_target(tepl_tkn_trnsltr_title, make_token_translator(tepl_lem_title)),
  tar_target(tepl_tkn_trnsltr_descr, make_token_translator(tepl_lem_descr)),
  tar_target(plt_wordfreqs, plot_wordfreq(tepl_texts, prj_nazev,
                                          tepl_tkn_trnsltr_title, 35,
                                          stopwords_all_cz,
                                          title = "Nejčastější slova v názvech")),
  tar_target(plt_wordpairs, plot_wordcorrs(tepl_texts, prj_shrnuti,
                                           tepl_tkn_trnsltr_title, 5,
                                           stopwords_all_cz,
                                           title = "Nejčastější společný výskyt slov v popisech projektů")),
  tar_target(bigram_data, prep_ngrams(tepl_texts, tepl_tkn_trnsltr_descr,
                                      prj_shrnuti, mess_cz = stopwords_all_cz,
                                      lemma = T, n = 2)),
  tar_target(bigram_data_nolemma, prep_ngrams(tepl_texts, tepl_tkn_trnsltr_descr,
                                              prj_shrnuti, mess_cz = stopwords_all_cz,
                                              lemma = F, n = 2)),
  tar_target(plt_bigram_bars, plot_ngrams_bars(bigram_data_nolemma, 50,
                                               title = "Nejčastější dvojslovná spojení v popisech projektů")),
  tar_target(plt_bigram_network, plot_ngrams_network(bigram_data, 5,
                                                     title = "Nejčastější dvojslovná spojení v popisech projektů")),
  tar_target(plt_topics, plot_topics(tepl_texts, prj_shrnuti,
                                     tepl_tkn_trnsltr_descr, 4, stopwords_all_cz,
                                     title = "Seskupení projektů do 4 témat",
                                     subtitle = "Relativně nejčastější slova v tématech"))
)

## Text analysis firmy ---------------------------------------------

t_text_firmy <- list(
  tar_target(firmy_texts, get_prj_texts(efs_tagged_sum_prj, sc_id == "01.3.10.3.2")),
  tar_target(firmy_lem_title, lemmatize_esif(efs_tagged_sum_prj, prj_nazev, .sample = NULL,
                                             sc_id == "01.3.10.3.2")),
  tar_target(firmy_lem_descr, lemmatize_esif(efs_tagged_sum_prj, prj_shrnuti, .sample = 2500,
                                             sc_id == "01.3.10.3.2")),
  tar_target(firmy_tkn_trnsltr_title, make_token_translator(firmy_lem_title)),
  tar_target(firmy_tkn_trnsltr_descr, make_token_translator(firmy_lem_descr)),
  tar_target(plt_wordfreqs_firmy, plot_wordfreq(firmy_texts, prj_nazev,
                                                firmy_tkn_trnsltr_title, 35,
                                                stopwords_all_cz,
                                                title = "Nejčastější slova v názvech")),
  tar_target(plt_wordpairs_firmy, plot_wordcorrs(firmy_texts, prj_shrnuti,
                                                 firmy_tkn_trnsltr_title, 30,
                                                 stopwords_all_cz,
                                                 title = "Nejčastější společný výskyt slov v popisech projektů")),
  tar_target(bigram_data_firmy, prep_ngrams(firmy_texts, firmy_tkn_trnsltr_descr,
                                            prj_shrnuti, mess_cz = stopwords_all_cz,
                                            lemma = T, n = 2)),
  tar_target(bigram_data_nolemma_firmy, prep_ngrams(firmy_texts, firmy_tkn_trnsltr_descr,
                                                    prj_shrnuti, mess_cz = stopwords_all_cz,
                                                    lemma = F, n = 2)),
  tar_target(plt_bigram_bars_firmy, plot_ngrams_bars(bigram_data_nolemma_firmy, 50,
                                                     title = "Nejčastější dvojslovná spojení v popisech projektů")),
  tar_target(plt_bigram_network_firmy, plot_ngrams_network(bigram_data_firmy, 50,
                                                           title = "Nejčastější dvojslovná spojení v popisech projektů")),
  tar_target(plt_topics_firmy, plot_topics(firmy_texts, prj_shrnuti,
                                           firmy_tkn_trnsltr_descr, 4, stopwords_all_cz,
                                           title = "Seskupení projektů do 4 témat",
                                           subtitle = "Relativně nejčastější slova v tématech"))
)


# Build and export codebook -----------------------------------------------

t_codebook <- list(
  tar_target(sum_codebook,
             make_codebook(esif_tagged_sum_op)),
  tar_file(sum_codebook_yaml,
           {informant_edit <- sum_codebook
           informant_edit$read_fn <- "data"
           pointblank::yaml_write(informant = informant_edit,
                                  path = c_export_dir,
                                  filename = c_export_cdbk_sum)
           file.path(c_export_dir, c_export_cdbk_sum)
           }),
  tar_target(prj_codebook,
             make_codebook(efs_tagged_sum_prj)),
  tar_file(prj_codebook_yaml,
           {informant_edit <- prj_codebook
           informant_edit$read_fn <- "data"
           pointblank::yaml_write(informant = informant_edit,
                                  path = c_export_dir,
                                  filename = c_export_cdbk_prj)
           file.path(c_export_dir, c_export_cdbk_prj)
           })
)

# HTML output -------------------------------------------------------------

source("R/html_output.R")

# Compile targets lists ---------------------------------------------------

list(t_public_list, t_sestavy, t_esif_compile, t_export, t_codebook, t_html,
     t_agri_opendata, t_opendata, t_esif_compile_withopendata, t_switch,
     t_mtagged_summarised, t_text_teplarny, t_text_firmy,
     t_climacat_reg, t_climacat_manual, t_hier, t_ec,
     t_climate_tag, t_tagged_summarised, t_tagging_aid, t_tagged_compiled,
     t_tagged_plots, t_prv_priorities, t_sample)
