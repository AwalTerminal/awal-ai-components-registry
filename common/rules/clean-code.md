# Clean Code Rules

## Naming
- Use descriptive, intention-revealing names
- Avoid abbreviations unless universally understood (e.g., `id`, `url`, `http`)
- Name booleans as questions: `isReady`, `hasPermission`, `canExecute`
- Name collections as plurals: `users`, `items`, `results`

## Functions
- Functions should do one thing and do it well
- Keep functions short — if it needs a comment to explain what a section does, extract it
- Limit parameters to 3 or fewer; use an options object/struct for more
- Avoid side effects — make them explicit in the function name if unavoidable

## Error Handling
- Handle errors at the appropriate level — don't catch and ignore
- Use specific error types, not generic strings
- Fail fast: validate inputs early and return/throw immediately
- Never swallow exceptions silently

## Comments
- Don't comment what the code does — make the code self-explanatory
- Comment *why*, not *what*
- Keep comments up to date or delete them
- Use TODO/FIXME with a description, never leave empty TODOs
