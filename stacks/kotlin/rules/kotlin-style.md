# Kotlin Style Rules

- Use `val` over `var` — immutability by default
- Use expression bodies for single-expression functions: `fun double(x: Int) = x * 2`
- Use `when` over `if-else` chains for multiple conditions
- Avoid `!!` — handle nullability explicitly with `?.`, `?:`, or `let`
- Use data classes for DTOs and value objects
- Use sealed classes for restricted type hierarchies
- Prefer extension functions over utility classes
- Use `require()` and `check()` for preconditions
