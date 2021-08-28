esifunguji
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->

TO DO

**Vytvořeno pro Centrum pro dopravu a energetiku jako součást projektu
*XXX* (CODE)**

Detailnější dokumentace k pipelinu na tvorbu dat pro makro modely:

-   [obsahová dokumentace](s_doc.html)
-   [vstupní validace dat](s_inputchecks.html)
-   [dokumantace a validace výstupu](s_output.html)
-   [technická dokumentace](dev.html)

## Dokumentace souborů

-   `esifunguji.Rproj`: konfigurace RStudio projektu
-   `_targets.R`: hlavní soubor definující datový pipeline
-   `_site.yml`: konfigurace webu generovaného uvnitř pipeline do složky
    `docs`
-   `_interactive.R`: konfigurace webu generovaného uvnitř pipeline do
    složky `docs`
-   `build.R`: utilita - spouští pipeline, v RStudio projectu navázáno
    na Build command
-   `*.Rmd`: zdroje webové dokumentace
-   `docs`: vygenerovaná webová dokumentace
-   `data-export`: exporty výstupních dat
-   `data-input`: vstupní data
-   `data-output`: výstupní data ve formátu pro R
-   `data-processed`: mezidata
-   `renv`: skladiště systému renv pro reprodukovatelnost prostředí
    (needitovat ručně)
-   `R`: kód funkcí, které dohromady vytváří pipeline
-   `scripts`: jiný kód mimo pipeline - odkladiště
-   `sp_data`: cache dat Státní pokladny

Detaily v [technické dokumentaci](dev.html).
