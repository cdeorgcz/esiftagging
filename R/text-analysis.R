source("_targets_packages.R")

get_prj_texts <- function(data, ...) {
  tepl_texts <- data |>
    filter(...) |>
    select(prj_id, prj_nazev, prj_shrnuti)
}

lemmatize_esif <- function(data, column, ...) {
  tepl_texts <- data |>
    # filter(sc_id == "01.3.15.3.5") |>
    filter(...) |>
    select(prj_id, prj_nazev, prj_shrnuti)


  tepl_string_descr <- tepl_texts |>
    # mutate(!!column := str_replace({{column}}, "prim\\.", "primární")) |>
    drop_na({{column}}) |>
    pull({{column}}) |>
    unique() |>
    paste(collapse = " ")

  # return(substr(tepl_string_descr, 1, 100))

  response_descr <- POST(url = "http://lindat.mff.cuni.cz/services/morphodita/api/tag",
                         body = list(
                           data = tepl_string_descr,
                           output = "json",
                           guesser = "no",
                           convert_tagset="strip_lemma_id")) |>
    stop_for_status()

  tokenised_descr <- content(response_descr, as = "text") |>
    fromJSON(simplifyDataFrame = T)
  tokresdf_descr <- tokenised_descr[["result"]] |>
    bind_rows(.id = "sentence") |>
    as_tibble()

  return(tokresdf_descr)
}

noise_cz <- c(".", ",", "\"", "\"", "-", ")", "(", ":", "/")
stopwords_cz_additional <- c("rámec", "včetně", "současný", "výstup",
                             "předmět", "cca", "nejen", "zejména", "nově",
                             "spočívat", "x", "ii")
stopwords_esif <- c("projekt", "ulice", "cíl", "přinést", "dojít", "rámec",
                    "součást", "výstup", "předmět", "oblast", "doba", "jednat",
                    "předpokládat", "hlavní", "versus", "realizace",
                    "předkládaný",
                    "zaměřovat", "docházet", "dojít", "akce", "část", "řešit", "uvedený",
                    "zaměřit", "aktivita", "podpora", "realizovat")

make_token_translator <- function(data) {
  tokenizer_joiner_title <- data |>
    select(token, lemma) |>
    mutate(token = tolower(token)) |>
    distinct()

  tokenizer_joiner_title
}

plot_wordcorrs <- function(data, variable, tkn_trnsltr, threshold = 5, mess_cz,
                           title = NULL, subtitle = NULL, caption = NULL) {
  tepl_paircor <- data |>
    unnest_tokens(word, {{variable}}) |>
    mutate(word = tolower(word)) |>
    left_join(tkn_trnsltr |> rename(word = token) |>
                mutate(word = tolower(word),
                       lemma = tolower(lemma))) |>
    filter(!lemma %in% c(mess_cz, stopwords_esif),
           lemma != "x",
           !str_detect(lemma, "^[0-9]")) |>
    group_by(lemma) |>
    filter(n() >= threshold) |>
    ungroup() |>
    # slice_sample(n = 100) |>
    pairwise_cor(lemma, prj_id, sort = TRUE, upper = FALSE)

  tepl_paircor

  tepl_paircor %>%
    filter(correlation > .3) %>%
    graph_from_data_frame() %>%
    ggraph(layout = "fr") +
    geom_edge_link(aes(edge_alpha = correlation, edge_width = correlation), edge_colour = "royalblue") +
    geom_node_point(size = 5) +
    geom_node_text(aes(label = name), repel = TRUE,
                   point.padding = unit(0.2, "lines")) +
    labs(title = title, subtitle = subtitle, caption = caption) +
    theme_void() +
    theme_ptrr("none", axis.text.x = element_blank(),
               axis.text.y = element_blank(), legend.position = "bottom")
}

# Topic modeling ----------------------------------------------------------

plot_topics <- function(data, variable, tkn_trnsltr, n = 4, mess_cz,
                        title = NULL, subtitle = NULL, caption = NULL) {
  tepl_words_cnt <- data |>
    unnest_tokens(word, {{variable}}) |>
    left_join(tkn_trnsltr |> rename(word = token) |>
                mutate(word = tolower(word),
                       lemma = tolower(lemma))) |>
    filter(!lemma %in% c(mess_cz, stopwords_esif),
           lemma != "x",
           !lemma %in% c("akciový", "společnost", "projekta"),
           !str_detect(lemma, "^[0-9]")) |>
    count(prj_id, lemma, sort = T)

  tepl_dtm <- tepl_words_cnt |>
    cast_dtm(prj_id, lemma, n)

  tepl_lda <- LDA(tepl_dtm, n)

  tepl_lda_tidy <- tepl_lda |>
    tidy()

  tepl_lda_tidy |>
    group_by(topic) |>
    slice_max(beta, n = 5) |>
    ggplot(aes(beta, term)) +
    geom_col() +
    facet_wrap(~topic, scales = "free_y") +
    theme_ptrr("x", multiplot = T) +
    labs(title = title, subtitle = subtitle, caption = caption) +
    scale_x_continuous(expand = flush_axis)
}

plot_wordfreq <- function(data, variable, tkn_trnsltr, n = 40, mess_cz,
                          title = NULL, subtitle = NULL, caption = NULL) {

  data %>%
    unnest_tokens(word, {{variable}}) |>
    left_join(tkn_trnsltr |> rename(word = token) |>
                mutate(word = tolower(word),
                       lemma = tolower(lemma))) |>
    group_by(lemma) %>%
    filter(!(lemma %in% c(mess_cz, stopwords_esif)),
           !lemma %in% c("projekt", "projekta"),
           !str_detect(lemma, "^[0-9]")) %>%
    tally(sort = T) %>%
    head(n) %>%
    mutate(lemma = fct_reorder(lemma, n)) %>%
    ggplot(aes(n, lemma)) +
    scale_x_continuous(expand = flush_axis) +
    geom_col() +
    labs(title = title, subtitle = subtitle, caption = caption) +
    theme_ptrr("x")

}

prep_ngrams <- function(data, tkn_trnsltr, variable, mess_cz,
                        lemma = T,
                        n = 2) {
  tepl_bigrams <- data |>
    select(prj_id, {{variable}}) |>
    unnest_tokens(bigram, {{variable}}, token = "ngrams", n = n)

  tepl_bigrams_separated <- tepl_bigrams |>
    separate(bigram, into = c("word1", "word2"), sep = " ") |>
    filter(!word1 %in% mess_cz, !word2 %in% mess_cz)

  tepl_bigrams_sep_lemmas <- tepl_bigrams_separated %>%
    left_join(tkn_trnsltr |> rename(word1 = token, word1_lemma = lemma) |>
                mutate(word1 = tolower(word1),
                       word1_lemma = tolower(word1_lemma))) |>
    left_join(tkn_trnsltr |> rename(word2 = token, word2_lemma = lemma) |>
                mutate(word2 = tolower(word2),
                       word2_lemma = tolower(word2_lemma)))

  tepl_bigrams_sep_clean <- tepl_bigrams_sep_lemmas |>
    filter(!word1_lemma %in% c(stopwords_esif, stopwords_cz_additional),
           !word2_lemma %in% c(stopwords_esif, stopwords_cz_additional),
           !word1 %in% c(stopwords_esif, stopwords_cz_additional),
           !word2 %in% c(stopwords_esif, stopwords_cz_additional),
           !str_detect(word1, "^[0-9]"),
           !str_detect(word2, "^[0-9]"),
           !str_detect(word1, "^[A-Z]([a-z]|[áéíúů])"),
           !str_detect(word2, "^[A-Z]([a-z]|[áéíúů])"))
  if (lemma) {
    rslt <- count(tepl_bigrams_sep_clean, word1_lemma, word2_lemma, sort = T) |>
      rename(word1 = word1_lemma, word2 = word2_lemma)

  }  else {
    rslt <- count(tepl_bigrams_sep_clean, word1, word2, sort = T)
  }

  return(rslt)

}

plot_ngrams_network <- function(data, threshold = 5,
                                title = NULL, subtitle = NULL, caption = NULL) {
  bigram_graph <- data |>
    filter(n > threshold) %>%
    graph_from_data_frame()

  ggraph(bigram_graph, layout = "fr") +
    geom_edge_link(aes(edge_width = n, edge_alpha = n), edge_colour = "royalblue") +
    geom_node_point() +
    labs(title = title, subtitle = subtitle, caption = caption) +
    theme_ptrr("none", axis.text.x = element_blank(),
               axis.text.y = element_blank(),
               legend.position = "bottom") +
    geom_node_label(aes(label = name), vjust = 1, hjust = 1)

}

plot_ngrams_bars <- function(data, n = 50,
                             title = NULL, subtitle = NULL, caption = NULL) {
  data |>
    unite(bigram, word1, word2, sep = " ") |>
    slice_max(n, n = n) |>
    mutate(bigram = as.factor(bigram) |> fct_reorder(n)) |>
    ggplot(aes(n, bigram)) +
    geom_col() +
    scale_x_number_cz(expand = ptrr::flush_axis) +
    labs(title = title, subtitle = subtitle, caption = caption) +
    ptrr::theme_ptrr("x", legend.position = "bottom")
}
