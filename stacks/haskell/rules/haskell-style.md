# Haskell Style Rules

- Use `ormolu` or `fourmolu` for consistent formatting
- Add explicit type signatures to all top-level definitions
- Prefer `Text` over `String` — add `OverloadedStrings` pragma when needed
- Use `hlint` and address all suggestions before committing
- Avoid orphan instances — define instances in the module that defines the type or the class
- Keep line length under 100 characters
- Use `qualified` imports for modules with common names: `import qualified Data.Map as Map`
- Write Haddock comments (`-- |`) for all exported functions
