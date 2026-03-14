# R Run & Test Commands

## Running Scripts

- `Rscript script.R` — run a script non-interactively
- `Rscript -e "source('script.R')"` — run via expression
- `R --no-save < script.R` — run in R session (see output in console)
- `R` — start interactive R session

## Package Development (devtools)

- `R -e "devtools::test()"` — run all tests
- `R -e "devtools::test(filter = 'money')"` — run tests matching pattern
- `R -e "devtools::check()"` — run R CMD check (full validation)
- `R -e "devtools::document()"` — regenerate roxygen2 documentation
- `R -e "devtools::load_all()"` — load package for interactive development
- `R -e "devtools::build()"` — build package tarball
- `R -e "devtools::install()"` — install package locally

## Linting and Formatting

- `R -e "lintr::lint_dir('R/')"` — lint source files
- `R -e "lintr::lint_package()"` — lint entire package
- `R -e "styler::style_dir('R/')"` — auto-format source files
- `R -e "styler::style_file('R/analysis.R')"` — format a single file
- `R -e "goodpractice::gp()"` — comprehensive package quality checks

## Dependency Management

- `R -e "renv::init()"` — initialize renv for the project
- `R -e "renv::restore()"` — restore project dependencies from lockfile
- `R -e "renv::snapshot()"` — update lockfile with current dependencies
- `R -e "renv::install('dplyr')"` — install a package into the project library
- `R -e "renv::update()"` — update all packages

## Testing

- `R -e "testthat::test_dir('tests/testthat')"` — run tests directly
- `R -e "covr::package_coverage()"` — measure test coverage
- `R -e "covr::report()"` — generate HTML coverage report

## Documentation

- `R -e "pkgdown::build_site()"` — build package documentation website
- `R -e "devtools::build_vignettes()"` — build vignettes
- `R -e "devtools::build_manual()"` — build PDF manual
