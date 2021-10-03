library(magrittr)
library(dplyr)
library(stringr)
op_labels <- tibble::tribble(
  ~op_id,                                                ~op_nazev,    ~op_zkr,
  "01", "Operační program Podnikání a inovace pro konkurenceschopnost", "OP PIK",
  "02",                  "Operační program Výzkum, vývoj a vzdělávání", "OP VVV",
  "03",                                "Operační program Zaměstnanost", "OP Z",
  "04",                                     "Operační program Doprava", "OP D",
  "05",                           "Operační program Životní prostředí", "OP ŽP",
  "06",                      "Integrovaný regionální operační program", "IROP",
  "07",                        "Operační program Praha - pól růstu ČR", "OP PPR",
  "08",                             "Operační program Technická pomoc", "OP TP",
  "11",                        "INTERREG V-A Česká republika - Polsko", "OP ČR-PL"
) %>%
  mutate(op_nazev_zkr = str_replace(op_nazev, "[Oo]perační program|INTERREG V-A", "OP") %>%
           str_replace("Česká republika", "ČR"))

add_op_labels <- function(data, abbrevs = op_labels,
                          drop_orig = TRUE, drop_duplicate_cols = T) {

  if(!"op_id" %in% names(data) & "prj_id" %in% names(data)) {
    data$op_id <- str_sub(data$prj_id, 4, 5)
  } else if ("op_zkr" %in% names(data)) {
    if(drop_orig) data$op_zkr <- NULL else data <- rename(data, op_zkr_orig = op_zkr)
  } else if ("op_nazev" %in% names(data)) {
    if(drop_orig) data$op_nazev <- NULL else data <- rename(data, op_nazev_org = op_nazev)
  }

  data2 <- data %>%
    left_join(abbrevs, by = "op_id", suffix = c("", "_lblx"))

  if(drop_duplicate_cols) data2 <- data2 %>% select(-ends_with("lblx"))

  return(data2)
}

export_table <- function(data, path, fun, ...) {

  fun(data, path, ...)

  return(path)
}

pc <- function(x, accuracy = 1) {
  ptrr::label_percent_cz(accuracy = accuracy)(x)
}

nm <- function(x, accuracy = 1) {
  ptrr::label_number_cz(accuracy = accuracy)(x)
}

bn <- function(x, accuracy = 1) {
  if(is.data.frame(x) & identical(dim(x), as.integer(c(1,1)))) x <- x[[1]]
  paste0(ptrr::label_number_cz(accuracy = accuracy)(x/1e9), " mld. Kč")
}
