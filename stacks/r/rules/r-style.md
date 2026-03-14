# R Style Rules

## Formatting
- Follow the tidyverse style guide — use `styler::style_file()` or `styler::style_dir()` for auto-formatting
- 2-space indentation (tidyverse convention)
- Keep lines under 80 characters — break long pipes across multiple lines
- One space around operators: `x <- 1 + 2`, not `x<-1+2`
- No spaces inside parentheses or brackets: `f(x)`, not `f( x )`

## Naming
- Variables and functions: `snake_case` (`calculate_total`, `user_id`)
- Never use dots as name separators (`user.id` is S3 method dispatch syntax)
- Boolean variables/functions: prefix with `is_` or `has_` (`is_valid`, `has_data`)
- Constants: `UPPER_SNAKE_CASE` (`MAX_RETRIES`, `DEFAULT_TIMEOUT`)
- File names: `snake_case.R`, matching the primary function or concept

## Assignment
- Use `<-` for assignment, not `=` — reserve `=` for function arguments
- Use `<<-` only inside closures, never at top level
- Avoid `->` (right assignment) entirely

## Functions
- Explicitly return values with `return()` only for early returns — final expression is returned implicitly
- Use named arguments when calling functions with more than 2 parameters
- Keep functions under 50 lines — extract helpers as internal functions
- Use `match.arg()` for string arguments with fixed options
- Validate inputs with `stopifnot()` or custom error messages via `stop()`

## Packages and Loading
- Use `library()` calls at the top of the script — never use `require()`
- Prefer `package::function()` for one-off uses instead of loading the whole package
- Never use `T`/`F` abbreviations — always spell out `TRUE`/`FALSE`
- Avoid `attach()` — it pollutes the search path

## Data
- Prefer tibbles over data.frames for better printing and stricter subsetting
- Use `NA` correctly — never use `NULL`, empty strings, or sentinels for missing data
- Be explicit about column types when reading data: `col_types` in `readr`

## Documentation
- Document exported functions with `roxygen2` (`#'` comments)
- Include `@param`, `@return`, `@examples`, and `@export` tags
- Write a package-level `_PACKAGE` documentation file

## Linting
- Run `lintr::lint_dir("R/")` and fix all warnings before committing
- Configure `.lintr` file for project-specific rules
- Use `goodpractice::gp()` for comprehensive package checks
