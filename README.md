ESIF climate tagging
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->

Climate tagging výdajů ESI fondů v ČR, 2014-20.

**Vytvořeno pro Centrum pro dopravu a energetiku jako součást projektu
LIFE *XXX* (CODE)**

Detailnější dokumentace k pipelinu na přípravu a tagging dat o výdajích
ESIF:

-   [obsahová dokumentace](s_doc.html)

-   [dokumentace a validace výstupu](s_output.html)

-   [pomůcka pro ruční tagging](s_listing.html)

-   [vstupní validace dat](s_inputchecks.html)

-   [technická dokumentace](dev.html)

## Dokumentace souborů

-   `esiftagging.Rproj`: konfigurace RStudio projektu
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
-   `site`: adresář pro pomocné soubory webové dokumentace - jejich
    změna spustí rebuild stránek; celý adresář se publikuje spolu s
    webovou dokumentací
-   `renv`: skladiště systému renv pro reprodukovatelnost prostředí
    (needitovat ručně)
-   `R`: kód funkcí, které dohromady vytváří pipeline
-   `scripts`: jiný kód mimo pipeline - odkladiště

Detaily v [technické dokumentaci](dev.html).
