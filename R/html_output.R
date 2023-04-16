t_html <- list(
  tar_file(s_readme_rmd, "README.Rmd"),
  tar_file(readme_md, ptrr::render_readme(s_readme_rmd)),
  tar_file(siteconf, "_site.yml"),
  tar_file(sitefiles, "site"),
  # https://github.com/jdblischak/workflowr/issues/238#issuecomment-782024069

  tar_file(s_index_html, command = {!! tar_knitr_deps_expr("README.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_readme_rmd)
    file.remove("docs/index.html")
    file.rename("docs/README.html", "docs/index.html")
    "docs/index.html"}),

  tar_file(s_doc_rmd, "s_doc.Rmd"),
  tar_file(s_doc_html, command = {!! tar_knitr_deps_expr("s_doc.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_doc_rmd)
    "docs/s_doc.html"}),

  tar_file(s_met_md, "s_doc.Rmd"),
  tar_file(s_met_html, command = {!! tar_knitr_deps_expr("s_metodologie.md")
    siteconf
    sitefiles
    rmarkdown::render_site(s_doc_rmd)
    "docs/s_doc.html"}),

  tar_file(s_inputchecks_rmd, "s_inputchecks.Rmd"),
  tar_file(s_inputchecks_html, command = {!! tar_knitr_deps_expr("s_inputchecks.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_inputchecks_rmd)
    "docs/s_inputchecks.html"}),

  tar_file(s_output_rmd, "s_output.Rmd"),
  tar_file(s_output_html, command = {!! tar_knitr_deps_expr("s_output.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_output_rmd)
    "docs/s_output.html"}),

  tar_file(s_dev_rmd, "dev.Rmd"),
  tar_file(s_dev_html, command = {!! tar_knitr_deps_expr("dev.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_dev_rmd)
    "docs/dev.html"}),

  tar_file(s_log_rmd, "log.Rmd"),
  tar_file(s_log_html, command = {!! tar_knitr_deps_expr("log.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_log_rmd)
    "docs/log.html"}),

  tar_file(s_research_rmd, "research.Rmd"),
  tar_file(s_research_html, command = {!! tar_knitr_deps_expr("research.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_research_rmd)
    "docs/research.html"}),

  tar_file(s_listing_rmd, "s_listing.Rmd"),
  tar_file(s_listing_html, command = {!! tar_knitr_deps_expr("s_listing.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_listing_rmd)
    "docs/s_listing.html"}),

  tar_file(s_sample_rmd, "sample.Rmd"),
  tar_file(s_sample_html, command = {!! tar_knitr_deps_expr("sample.Rmd")
    siteconf
    sitefiles
    rmarkdown::render_site(s_sample_rmd)
    "docs/sample.html"})
)
