ESIF climate tagging
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->

Climate tagging výdajů ESI fondů v ČR, 2014-20.

**Vytvořeno pro Centrum pro dopravu a energetiku jako součást projektu
LIFE *XXX* (CODE)**

Poznatky byly využity ve výstupech CDE a Fakt o klimatu v květnu 2022:

- infografika [Fakta o
  klimatu](https://faktaoklimatu.cz/infografiky/fondy-eu-cde)
- [Policy
  Brief](https://www.cde-org.cz/media/object/1972/revize_climate_taggingu_evropskych_fondu_v_ceske_republice.pdf)
- [tisková zpráva CDE 26. 5.
  2022](https://www.cde-org.cz/cs/blog/cesko-zaostava-v-podpore-zelenych-investic-odhaluje-nova-analyza-z-evropskych-fondu-financuje-i-projekty-s-prokazatelne-negativnim-dopadem-na-klima/1973):
  **Česko zaostává v podpoře zelených investic, odhaluje nová analýza. Z
  evropských fondů financuje i projekty s prokazatelně negativním
  dopadem na klima**

Data aktualizována po datu publikace studie. Poslední data pochází z 16.
dubna 2023 ([otevřená
data](https://data.gov.cz/datov%C3%A1-sada?iri=https://data.gov.cz/zdroj/datov%C3%A9-sady/66002222/af32ce8f398945f72b65a7215e2ec78e)),
popř. 1. dubna 2023 (veřejný [seznam
operací](https://dotaceeu.cz/cs/statistiky-a-analyzy/seznam-operaci-(prijemcu))).

Detailnější dokumentace k pipelinu na přípravu a tagging dat o výdajích
ESIF:

- [metodologie](s_metodologie.html)

- [vizualizace výstupu](s_output.html)

- [obsahová dokumentace](s_doc.html)

- [pomůcka pro ruční tagging](s_listing.html)

- [vstupní validace dat](s_inputchecks.html)

- [technická dokumentace](dev.html)

## Dokumentace souborů

- `esiftagging.Rproj`: konfigurace RStudio projektu
- `_targets.R`: hlavní soubor definující datový pipeline
- `_site.yml`: konfigurace webu generovaného uvnitř pipeline do složky
  `docs`
- `_interactive.R`: utilita - načítá objekty pro interaktivní vývoj
- `build.R`: utilita - spouští pipeline, v RStudio projectu navázáno na
  Build command
- `*.Rmd`: zdroje webové dokumentace
- `docs`: vygenerovaná webová dokumentace
- `data-export`: exporty výstupních dat
- `data-input`: vstupní data
- `data-output`: výstupní data ve formátu pro R
- `data-processed`: mezidata
- `site`: adresář pro pomocné soubory webové dokumentace - jejich změna
  spustí rebuild stránek; celý adresář se publikuje spolu s webovou
  dokumentací
- `renv`: skladiště systému renv pro reprodukovatelnost prostředí
  (needitovat ručně)
- `R`: kód funkcí, které dohromady vytváří pipeline
- `scripts`: jiný kód mimo pipeline - odkladiště

Detaily v [technické dokumentaci](dev.html).
