# R Patterns

## Data Manipulation
- Use `dplyr` verbs (`filter`, `select`, `mutate`, `summarise`, `arrange`) for data transformations
- Prefer the pipe `|>` or `%>%` to chain operations for readable data pipelines
- Use `tidyr::pivot_longer` and `pivot_wider` instead of `reshape`
- Vectorize operations — avoid explicit `for` loops when possible
- Use `data.table` for large datasets where `dplyr` performance is insufficient

## Functional Style
- Use `purrr::map` family instead of `lapply`/`sapply` for consistent return types
- Write small, composable functions — each function does one thing
- Use `tryCatch` for error handling, `purrr::safely` for wrapping fallible functions
- Avoid modifying global state — pass data in and return data out
- Use default parameter values for optional configuration

## Project Structure
- Use an R package structure (`R/`, `man/`, `tests/`) even for analysis projects
- Keep data loading, analysis, and visualization in separate scripts or functions
- Use `renv` for reproducible dependency management
- Store configuration in a YAML or JSON file, not hardcoded in scripts

## Visualization
- Use `ggplot2` as the primary plotting library — build plots in layers
- Define a custom theme once and reuse it across all plots
- Use `ggsave()` with explicit dimensions for reproducible output
- Label axes and titles clearly — a plot should be interpretable without reading the code

## Testing
- Use `testthat` for unit tests — organize in `tests/testthat/`
- Test data transformation functions with known input-output pairs
- Use `withr` for temporary side effects in tests (temp files, options)
- Run `devtools::test()` to execute all tests
