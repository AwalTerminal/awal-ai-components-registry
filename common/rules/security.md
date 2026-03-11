# Security Rules

## Input Validation
- Validate all input at system boundaries (HTTP handlers, CLI args, file parsers)
- Use allowlists over denylists when possible
- Sanitize output based on context (HTML, SQL, shell)
- Never trust client-side validation alone

## Secrets
- Never hardcode secrets, API keys, or credentials in source code
- Use environment variables or secret management services
- Never log secrets, tokens, or passwords — even at debug level
- Rotate credentials regularly and support rotation without downtime

## Authentication & Authorization
- Use established libraries for auth — don't roll your own crypto
- Enforce least-privilege: grant minimum permissions needed
- Validate authorization on every request, not just at the entry point
- Use constant-time comparison for secrets and tokens

## Data Protection
- Encrypt sensitive data at rest and in transit
- Use parameterized queries — never concatenate SQL
- Sanitize file paths to prevent directory traversal
- Set appropriate CORS, CSP, and security headers
