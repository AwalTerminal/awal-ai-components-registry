# Security Rules

## OWASP Top 10 — Detection and Prevention

### A01: Broken Access Control

- Every endpoint must enforce authorization checks server-side, not just in the UI.
- Deny by default: if no explicit policy grants access, the request is rejected.
- Validate object ownership on every data access: `GET /api/orders/123` must verify that the authenticated user owns order 123.
- Disable directory listing on web servers. Return 404, not 403, for unauthorized resources (prevents enumeration).

**Detection pattern:** Search for data-fetching functions that accept a user-supplied ID but lack an ownership or role check.

### A02: Cryptographic Failures

- Use TLS 1.2+ for all data in transit. Reject TLS 1.0/1.1.
- Hash passwords with bcrypt (cost ≥ 12), scrypt, or argon2id. Never MD5 or SHA-256 alone.
- Encrypt sensitive data at rest with AES-256-GCM. Never use ECB mode.
- Do not invent custom cryptographic schemes.

**Detection pattern:** Search for `md5(`, `sha1(`, `DES`, `ECB`, or raw `encrypt(` calls without authenticated encryption.

### A03: Injection

- Use parameterized queries for all database access. Never concatenate user input into SQL.
- Sanitize output by context: HTML-encode for HTML, JS-encode for JavaScript, URL-encode for URLs.
- Use allowlists for dynamic file paths, shell arguments, and LDAP queries.

```
# BAD — SQL injection
query = f"SELECT * FROM users WHERE id = {user_id}"

# GOOD — parameterized
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))
```

### A04: Insecure Design

- Apply threat modeling during design (STRIDE or attack trees).
- Define trust boundaries: user input, third-party APIs, internal services, database.
- Enforce rate limiting on authentication, password reset, and any endpoint that triggers external actions (email, SMS).
- Implement account lockout after 5 failed login attempts within 15 minutes.

### A05: Security Misconfiguration

- Disable debug mode, stack traces, and verbose error messages in production.
- Remove default credentials, sample apps, and unnecessary HTTP methods.
- Set restrictive file permissions: config files readable only by the application user.
- Automate configuration hardening via infrastructure-as-code.

### A06: Vulnerable and Outdated Components

- Run `npm audit` / `pip audit` / `cargo audit` in CI — fail the build on high/critical.
- Pin dependencies to exact versions. Use lock files (`package-lock.json`, `Cargo.lock`, `poetry.lock`).
- Review changelogs before upgrading major versions.
- Remove unused dependencies. Every dependency is attack surface.

### A07: Identification and Authentication Failures

- Enforce minimum password length of 12 characters. Check against breached password lists (HaveIBeenPwned API).
- Implement multi-factor authentication for privileged accounts.
- Use secure session management: HttpOnly, Secure, SameSite=Strict cookies.
- Invalidate sessions on logout, password change, and privilege escalation.

### A08: Software and Data Integrity Failures

- Verify signatures and checksums on all downloaded artifacts and dependencies.
- Use Subresource Integrity (SRI) hashes for CDN-hosted scripts and styles.
- Protect CI/CD pipelines: require signed commits, restrict who can modify build configs.

### A09: Security Logging and Monitoring Failures

- Log all authentication events (success and failure), authorization failures, and input validation failures.
- Include timestamp (UTC ISO 8601), source IP, user ID, action, and outcome in every log entry.
- Send security logs to a centralized, append-only system with alerting.
- Review logs regularly and alert on anomalies (spike in 401s, login attempts from new geographies).

### A10: Server-Side Request Forgery (SSRF)

- Validate and allowlist destination URLs for all server-initiated HTTP requests.
- Block requests to internal IP ranges: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.0/8`, `169.254.169.254`.
- Do not expose raw URL-fetching capabilities to end users without strict validation.

## Trust Boundary Analysis

Identify every point where data crosses a trust boundary. Each crossing requires validation:

| Boundary | Incoming data | Required validation |
|---|---|---|
| HTTP request → Application | Headers, body, query params, cookies | Schema validation, type checking, size limits |
| Application → Database | Query parameters | Parameterized queries, ORM escaping |
| Application → External API | Responses | Schema validation, timeout, error handling |
| File system → Application | File contents, filenames | Path traversal check, type validation, size limits |
| User upload → Storage | File bytes | Extension allowlist, MIME check, virus scan, size limit |
| Environment → Application | Env vars, config files | Presence check, type validation at startup |

## Secrets Detection

### Patterns to scan for in code and CI

These regex patterns detect common secret leaks. Run them in pre-commit hooks and CI:

| Secret type | Regex pattern |
|---|---|
| AWS Access Key | `AKIA[0-9A-Z]{16}` |
| AWS Secret Key | `(?i)aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}` |
| GitHub Token | `gh[ps]_[A-Za-z0-9_]{36,}` |
| Generic API Key | `(?i)(api[_-]?key\|apikey)\s*[:=]\s*['"][A-Za-z0-9]{20,}['"]` |
| JWT | `eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}` |
| Private Key | `-----BEGIN (RSA\|EC\|OPENSSH) PRIVATE KEY-----` |
| Slack Token | `xox[bpras]-[A-Za-z0-9-]{10,}` |
| Generic password | `(?i)(password\|passwd\|pwd)\s*[:=]\s*['"][^'"]{8,}['"]` |

### Rules

- Use tools like `gitleaks`, `trufflehog`, or `detect-secrets` as pre-commit hooks.
- Store secrets in a vault (AWS Secrets Manager, HashiCorp Vault, 1Password) — never in environment files committed to the repo.
- Rotate any secret that has ever appeared in version control, even in a reverted commit.
- `.env` files must be in `.gitignore`. Provide `.env.example` with placeholder values only.

## Supply Chain Security

- Enable dependency lock files and commit them to the repository.
- Use `npm audit`, `pip audit`, `cargo audit`, or equivalent in every CI run.
- Pin GitHub Actions to full commit SHAs, not tags: `uses: actions/checkout@a81bbbf...`, not `@v3`.
- Verify package integrity: enable npm `--ignore-scripts` for untrusted packages, review postinstall scripts.
- Use SRI hashes for all externally loaded scripts: `<script src="..." integrity="sha384-..." crossorigin="anonymous">`.
- Minimize dependency count. Evaluate whether a dependency is worth the risk before adding it.

## Authentication Patterns

### Session-Based Auth

- Generate session IDs with a CSPRNG, minimum 128 bits of entropy.
- Store sessions server-side (Redis, database). Never store session data in the cookie itself.
- Set cookie flags: `HttpOnly`, `Secure`, `SameSite=Strict`, reasonable `Max-Age`.
- Regenerate session ID after login to prevent session fixation.

### JWT Auth

- Sign with RS256 or ES256 for service-to-service. HS256 only when both parties share a secret securely.
- Never use `alg: none`. Validate the `alg` header against an allowlist.
- Set short expiration (15 minutes for access tokens). Use refresh tokens with rotation.
- Store JWTs in HttpOnly cookies, not localStorage (XSS-accessible).
- Include `iss`, `aud`, `exp`, and `iat` claims. Validate all of them.

### Common Mistakes

- Accepting tokens from query strings (logged in server access logs, browser history).
- Not invalidating tokens on logout (maintain a token denylist or use short-lived tokens with refresh rotation).
- Storing passwords with reversible encryption instead of hashing.

## Authorization Patterns

### RBAC (Role-Based Access Control)

- Define roles as sets of permissions, not ad-hoc string checks.
- Check permissions, not roles, in application code: `user.can("orders:delete")` not `user.role == "admin"`.
- Enforce authorization in middleware/decorators, not scattered through business logic.

### Bypass Prevention

- Always re-validate authorization server-side. Client-side role checks are for UX only.
- Prevent parameter tampering: do not trust `user_id` from the request body; derive it from the authenticated session.
- Test for privilege escalation: can a regular user access admin endpoints by changing the URL?
- Test for IDOR: can user A access user B's resources by changing the resource ID?

## HTTP Security Headers

Apply these headers on every HTTP response:

| Header | Value | Purpose |
|---|---|---|
| `Content-Security-Policy` | `default-src 'self'; script-src 'self'` | Prevent XSS, injection |
| `Strict-Transport-Security` | `max-age=63072000; includeSubDomains; preload` | Force HTTPS |
| `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
| `X-Frame-Options` | `DENY` | Prevent clickjacking |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Limit referrer leakage |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=()` | Restrict browser features |
| `X-XSS-Protection` | `0` | Disable buggy legacy filter; rely on CSP |

## File Upload Security

- Restrict allowed MIME types via allowlist. Validate by reading file magic bytes, not just the extension.
- Limit file size (enforce server-side, not just client-side).
- Store uploads outside the web root. Serve via a controller that sets `Content-Disposition: attachment`.
- Rename uploaded files to random UUIDs. Never use the original filename in the storage path.
- Scan uploads for malware if the application handles untrusted content.
- Strip EXIF metadata from images before storing (privacy and potential exploit vectors).

## Rate Limiting and DoS Prevention

- Rate-limit authentication endpoints: max 10 attempts per IP per minute.
- Rate-limit API endpoints per authenticated user: define sensible defaults (e.g., 100 req/min) and document them.
- Use exponential backoff for retry-after responses (429 status code with `Retry-After` header).
- Set request body size limits at the reverse proxy and application level.
- Implement connection timeouts and request deadlines to prevent slowloris-style attacks.
- Use CAPTCHAs or proof-of-work challenges on public forms (registration, password reset).

## Logging Security

### What to Log

- Authentication events (login success, failure, logout, MFA challenge).
- Authorization failures (403 responses, permission denials).
- Input validation failures.
- System errors and exceptions.
- Administrative actions (user creation, role changes, config modifications).

### What Never to Log

- Passwords, password hashes, or password reset tokens.
- Session tokens, API keys, or JWTs.
- Credit card numbers (log last 4 digits at most).
- Social security numbers, government IDs.
- Full request bodies containing PII — log a sanitized summary.
- Encryption keys or secrets of any kind.

### Log Format

Every security-relevant log entry must include:
- Timestamp in UTC ISO 8601 (`2024-01-15T08:30:00Z`)
- Event type (`auth.login.failure`)
- Source IP address
- User identifier (if authenticated)
- Action performed
- Outcome (success/failure)
- Request ID for correlation
