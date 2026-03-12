# R Style Rules

- Follow the tidyverse style guide — use `styler::style_file()` for auto-formatting
- Use `snake_case` for variable and function names — never use dots as separators
- Use `<-` for assignment, not `=` — reserve `=` for function arguments
- Use `lintr` and fix all warnings before committing
- Prefer `library()` calls at the top of the script — never use `require()`
- Document exported functions with `roxygen2` (`#'` comments)
- Keep lines under 80 characters — break long pipes across multiple lines
- Avoid `T`/`F` abbreviations — always spell out `TRUE`/`FALSE`
