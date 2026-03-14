# R Patterns

## Tidyverse Data Manipulation

```r
library(dplyr)
library(tidyr)

# Core dplyr verbs in a pipeline
sales_summary <- sales |>
  filter(year >= 2023, !is.na(revenue)) |>
  mutate(profit_margin = profit / revenue) |>
  group_by(region, quarter) |>
  summarise(
    total_revenue = sum(revenue),
    avg_margin = mean(profit_margin),
    n_deals = n(),
    .groups = "drop"
  ) |>
  arrange(desc(total_revenue))

# Pivoting data
wide_data <- long_data |>
  pivot_wider(names_from = metric, values_from = value, values_fill = 0)

long_data <- wide_data |>
  pivot_longer(cols = -id, names_to = "metric", values_to = "value")

# Joining tables
enriched <- orders |>
  left_join(customers, by = "customer_id") |>
  left_join(products, by = "product_id")
```

## Vectorization Over Loops

```r
# BAD: explicit loop
result <- numeric(length(x))
for (i in seq_along(x)) {
  result[i] <- x[i]^2 + 1
}

# GOOD: vectorized operation — 10-100x faster
result <- x^2 + 1

# Conditional vectorized operations
category <- ifelse(score >= 90, "A", ifelse(score >= 80, "B", "C"))

# Better for complex conditions: dplyr::case_when
category <- case_when(
  score >= 90 ~ "A",
  score >= 80 ~ "B",
  score >= 70 ~ "C",
  TRUE ~ "F"
)
```

## Functional Programming with purrr

```r
library(purrr)

# map variants with type-safe output
file_sizes <- map_dbl(file_list, file.size)
contents <- map_chr(urls, \(u) httr2::resp_body_string(httr2::req_perform(httr2::request(u))))

# Safely wrap fallible functions
safe_read <- safely(read.csv)
results <- map(file_paths, safe_read)
successes <- map(results, "result") |> compact()
errors <- map(results, "error") |> compact()

# Iterate over multiple inputs
pmap(list(url = urls, path = paths, timeout = timeouts), function(url, path, timeout) {
  download.file(url, path, timeout = timeout)
})

# Reduce for accumulation
all_data <- reduce(data_frames, bind_rows)

# Walk for side effects (returns input invisibly)
walk(plot_list, \(p) ggsave(paste0(p$name, ".png"), p$plot))
```

## Environments and Scoping

```r
# R uses lexical scoping — functions capture their enclosing environment
make_counter <- function() {
  count <- 0
  list(
    increment = function() { count <<- count + 1; count },
    get = function() count,
    reset = function() { count <<- 0 }
  )
}

counter <- make_counter()
counter$increment()  # 1
counter$increment()  # 2
counter$get()        # 2
```

## OOP: S3, S4, and R6

```r
# S3 — informal, flexible (most common)
new_money <- function(amount, currency = "USD") {
  structure(list(amount = amount, currency = currency), class = "money")
}
print.money <- function(x, ...) cat(sprintf("%s %.2f\n", x$currency, x$amount))
`+.money` <- function(a, b) {
  stopifnot(a$currency == b$currency)
  new_money(a$amount + b$amount, a$currency)
}

# R6 — reference semantics, mutable (for stateful objects)
library(R6)
Cache <- R6Class("Cache",
  public = list(
    initialize = function(max_size = 100) {
      private$store <- list()
      private$max_size <- max_size
    },
    get = function(key) private$store[[key]],
    set = function(key, value) {
      if (length(private$store) >= private$max_size) private$evict()
      private$store[[key]] <- value
    }
  ),
  private = list(
    store = NULL,
    max_size = NULL,
    evict = function() private$store[[1]] <- NULL
  )
)
```

## Performance: data.table vs dplyr

```r
library(data.table)

# data.table for large datasets (>1M rows) — 5-50x faster than dplyr
dt <- as.data.table(sales)

# Filtering and aggregation
dt[year >= 2023 & !is.na(revenue),
   .(total = sum(revenue), avg = mean(revenue)),
   by = .(region, quarter)][order(-total)]

# Update by reference — no copy
dt[, profit_margin := profit / revenue]
dt[region == "US", flagged := TRUE]

# Fast grouped operations
dt[, .SD[which.max(revenue)], by = region]
```

## Rcpp for Hot Paths

```r
library(Rcpp)

# Inline C++ for compute-intensive loops
cppFunction('
  double weighted_sum(NumericVector x, NumericVector w) {
    double total = 0;
    for (int i = 0; i < x.size(); i++) {
      total += x[i] * w[i];
    }
    return total;
  }
')

weighted_sum(values, weights)  # 10-100x faster than R loop
```

## Testing with testthat

```r
# tests/testthat/test-money.R
test_that("money addition works for same currency", {
  a <- new_money(10, "USD")
  b <- new_money(20, "USD")
  result <- a + b
  expect_equal(result$amount, 30)
  expect_equal(result$currency, "USD")
})

test_that("money addition fails for different currencies", {
  a <- new_money(10, "USD")
  b <- new_money(20, "EUR")
  expect_error(a + b)
})

# Snapshot tests for complex output
test_that("summary table renders correctly", {
  expect_snapshot(create_summary_table(sample_data))
})
```
