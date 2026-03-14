# Docker Style and Security Rules

## Dockerfile Conventions

- Use multi-stage builds — the final stage must use a minimal base (`alpine`, `slim`, `distroless`, `scratch`)
- Pin base image tags to specific versions: `FROM node:20.11-bookworm-slim`, never `FROM node:latest`
- For maximum reproducibility, pin to digest: `FROM node@sha256:abc123...`
- Use `COPY` instead of `ADD` unless you specifically need tar extraction or URL fetching
- Combine `RUN` commands with `&&` to reduce layers — always clean up caches in the same layer
- Order instructions from least to most frequently changing to maximize cache hits
- Use `.dockerignore` in every project — exclude `.git`, `node_modules`, build artifacts, test files, docs
- One `ENTRYPOINT` per Dockerfile — use `CMD` for default arguments that can be overridden
- Prefer exec form `["executable", "arg"]` over shell form for `CMD` and `ENTRYPOINT` — exec form receives signals properly

## Security Rules

- **Non-root execution:** Every production Dockerfile must include a `USER` instruction before `CMD`/`ENTRYPOINT`. Create a dedicated user with `useradd -r` or use `nonroot` in distroless images.
- **No secrets in images:** Never use `ENV` or `ARG` for secrets — they persist in image layers and history. Use `--mount=type=secret` for build-time secrets. Inject runtime secrets via environment variables or mounted files.
- **No sensitive files in context:** Ensure `.dockerignore` excludes `.env`, `*.pem`, `*.key`, `credentials.json`, and similar files.
- **Read-only filesystem:** Run containers with `--read-only` where possible. Use `tmpfs` mounts for directories that need writes.
- **Drop capabilities:** Run with `--cap-drop=ALL` and add back only what is needed.
- **No privileged mode:** Never use `--privileged` in production — it gives full host access.
- **Scan images in CI:** Run `trivy`, `grype`, or `docker scout` on every build. Fail on HIGH/CRITICAL vulnerabilities.
- **Use `HEALTHCHECK`:** Every production Dockerfile must define a health check.
- **No `sudo` in containers:** If the Dockerfile needs root for setup, do it before the `USER` instruction. Never install or use `sudo` at runtime.
- **Limit resource consumption:** Set memory and CPU limits via `deploy.resources.limits` in Compose or orchestrator configuration.

## Compose Conventions

- Use `compose.yaml` as the filename (Docker Compose V2 default)
- Define `healthcheck` on every service — use `depends_on` with `condition: service_healthy` for startup ordering
- Use named volumes for persistent data — bind mounts only for development
- Use user-defined bridge networks — never rely on the default bridge network
- Use `profiles` to group optional services (monitoring, debugging, testing)
- Use `.env` files for environment-specific values — never commit `.env` to version control, commit `.env.example`
- Set logging limits on all services: `max-size: "10m"`, `max-file: "3"`
- Use Compose secrets for sensitive values — reference `secrets` from files, not inline environment variables
- Pin all service image tags — no `latest` or untagged references in any environment

## Image Hygiene

- Run `hadolint` on every Dockerfile — fix all warnings before merging
- Keep final images under 200MB for application containers — investigate if larger
- Run `docker image prune` regularly on CI runners to reclaim disk space
- Use `docker history` to audit layer sizes and identify bloat
- Never install development tools (`gcc`, `make`, `git`) in the runtime stage
- Remove package manager caches in the same `RUN` layer: `rm -rf /var/lib/apt/lists/*`

## Tagging Strategy

- Use semantic versioning for release images: `myapp:1.2.3`
- Tag CI builds with the git SHA: `myapp:abc1234`
- Use environment tags only for deployment tracking, not as image identifiers: `myapp:1.2.3` deployed as `staging`
- Never overwrite a versioned tag — tags must be immutable once pushed to a registry
- Delete untagged and orphaned images from the registry on a schedule

## Networking Rules

- Expose only the ports that require external access — internal services communicate via the Compose network
- Use service names as hostnames within a Compose network — never hardcode container IPs
- Isolate frontend and backend services on separate networks when they do not need direct communication
- Use `network_mode: host` only when bridge networking introduces unacceptable latency — document the reason
