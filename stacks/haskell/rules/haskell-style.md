# Haskell Style Rules

## Formatting
- Use `ormolu` or `fourmolu` for consistent formatting — run before every commit
- Keep line length under 100 characters
- Use 2-space indentation consistently
- Align `where` clauses at the same level as the function body

## Naming
- Type names and constructors: `PascalCase`
- Functions and variables: `camelCase`
- Modules: `PascalCase` with dot-separated hierarchy (`MyApp.Auth.Token`)
- Type variables: single lowercase letters (`a`, `b`) or descriptive (`elem`, `key`)

## Types and Signatures
- Add explicit type signatures to ALL top-level definitions
- Use `newtype` wrappers for domain-specific primitives (`UserId`, `Email`)
- Prefer `Text` over `String` everywhere — enable `OverloadedStrings`
- Use strict fields (`!`) in data types unless laziness is specifically needed
- Avoid partial functions: no `head`, `tail`, `fromJust`, `read` — use safe alternatives

## Imports
- Use `qualified` imports for modules with common names: `import qualified Data.Map.Strict as Map`
- Group imports: base/prelude, external packages, internal modules — separated by blank lines
- Use explicit import lists for small imports: `import Data.Maybe (fromMaybe, isJust)`
- Never use wildcard imports from external packages in library code

## Functions
- Prefer point-free style only when it improves readability — never obscure intent
- Use `where` for helper definitions, `let` for intermediate bindings in do-blocks
- Prefer `foldl'` (strict) over `foldl` — avoid space leaks
- Keep functions under 30 lines — extract helpers into `where` clauses or separate functions
- Use guards over nested `if-then-else`

## Error Handling
- Use `Either AppError a` for recoverable errors — define a custom error ADT
- Use `ExceptT` to compose failable operations in monadic contexts
- Never throw exceptions in pure code — reserve `IO` exceptions for truly exceptional cases
- Document all partial patterns with a comment explaining why they are safe

## Instances
- Avoid orphan instances — define instances where the type or class is defined
- Use `deriving` strategies explicitly: `deriving stock (Show)`, `deriving newtype (Num)`
- Prefer `DerivingVia` for mechanical instances over manual boilerplate

## Documentation
- Write Haddock comments (`-- |`) for all exported functions and types
- Include at least one usage example in module-level documentation
- Document preconditions and invariants for unsafe operations

## Linting
- Run `hlint` on all source files and address every suggestion before committing
- Enable `-Wall -Wcompat -Wincomplete-record-updates -Wincomplete-uni-patterns`
- Treat warnings as errors in CI: `ghc-options: -Werror`
