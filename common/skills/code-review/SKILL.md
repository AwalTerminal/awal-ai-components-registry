# Code Review

When reviewing code, follow these guidelines:

## Checklist
- Check for correctness: does the code do what it claims?
- Check for edge cases and error handling
- Check for security vulnerabilities (injection, XSS, secrets in code)
- Check for performance issues (N+1 queries, unnecessary allocations, blocking calls)
- Check for readability and maintainability
- Check that tests cover the changes adequately

## Style
- Be constructive, not critical
- Suggest specific improvements with code examples
- Distinguish between "must fix" and "nice to have"
- Acknowledge good patterns when you see them

## Common Issues to Flag
- Hardcoded secrets or credentials
- Missing input validation at system boundaries
- Unbounded loops or recursion
- Resource leaks (unclosed connections, file handles)
- Race conditions in concurrent code
- Breaking changes to public APIs without version bump
