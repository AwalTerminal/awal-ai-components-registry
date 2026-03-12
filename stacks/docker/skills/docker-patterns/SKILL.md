# Docker Patterns

## Image Optimization
- Use multi-stage builds to keep final images small — build in one stage, copy artifacts to a minimal base
- Start `FROM` a specific tag, not `latest` — pin digest for reproducibility
- Order `COPY` statements by change frequency — static dependencies first, source code last
- Combine `RUN` commands with `&&` to reduce layers — clean up caches in the same layer
- Use `.dockerignore` to exclude build artifacts, `.git`, `node_modules`, etc.

## Security
- Run containers as a non-root user: `USER 1001` or `USER appuser`
- Use `COPY --chown` to set file ownership without extra `RUN` layers
- Scan images with `docker scout`, `trivy`, or `grype` before deploying
- Avoid installing unnecessary packages — use `--no-install-recommends` with apt
- Never store secrets in image layers — use build-time secrets or runtime env vars

## Compose Patterns
- Use `compose.yaml` (v2) as the default filename
- Define health checks for all services: `healthcheck.test`, `interval`, `timeout`
- Use named volumes for persistent data — bind mounts for development only
- Use `depends_on` with `condition: service_healthy` for startup ordering
- Use `.env` files for environment-specific configuration

## Networking
- Use user-defined bridge networks — never rely on the default bridge
- Expose only the ports that need external access
- Use service names as hostnames within a Compose network
- Use `network_mode: host` only when bridge networking is insufficient

## Development Workflow
- Use `docker compose watch` or bind mounts for live-reload during development
- Use `docker compose profiles` to group services (e.g., `debug`, `monitoring`)
- Keep `docker-compose.override.yml` for local development overrides
- Use `docker buildx` for multi-platform builds
