# R Run & Test

Run with Rscript or devtools:
- `Rscript script.R` — run a script
- `R -e "devtools::test()"` — run all tests
- `R -e "devtools::check()"` — run R CMD check
- `R -e "lintr::lint_dir('R/')"` — lint source files
- `R -e "styler::style_dir('R/')"` — auto-format source files
- `R -e "renv::restore()"` — restore project dependencies
- `R -e "devtools::document()"` — regenerate documentation
