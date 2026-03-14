# Docker Patterns

## Multi-Stage Build Architecture

### Standard Application Pattern

Separate build dependencies from runtime to minimize final image size:

```dockerfile
# Stage 1: Build
FROM node:20-bookworm AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit
COPY . .
RUN npm run build

# Stage 2: Runtime
FROM node:20-bookworm-slim AS runtime
WORKDIR /app
RUN groupadd -r appuser && useradd -r -g appuser -s /sbin/nologin appuser
COPY --from=builder --chown=appuser:appuser /app/dist ./dist
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appuser /app/package.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1) })"
CMD ["node", "dist/server.js"]
```

### Compiled Language Pattern (Go, Rust)

Build a static binary, deploy on scratch or distroless:

```dockerfile
FROM golang:1.22-bookworm AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app /app
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]
```

### Test Stage Pattern

Include tests as a build stage — CI runs the test stage, production skips it:

```dockerfile
FROM golang:1.22-bookworm AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .

FROM builder AS tester
RUN go test -race -cover ./...

FROM builder AS compiler
RUN CGO_ENABLED=0 go build -o /app ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=compiler /app /app
ENTRYPOINT ["/app"]
```

```bash
# Run tests only
docker build --target tester .
# Build production image (skips test stage)
docker build --target runtime .
```

## Layer Optimization

### Instruction Ordering

Order instructions from least to most frequently changing:

```dockerfile
FROM python:3.12-slim

# 1. System dependencies (rarely change)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq5 && \
    rm -rf /var/lib/apt/lists/*

# 2. Python dependencies (change on requirements.txt update)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Application code (changes on every commit)
COPY . .
```

### Cache Mounts (BuildKit)

Use BuildKit cache mounts to persist package manager caches across builds:

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.12-slim
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

FROM node:20-slim
RUN --mount=type=cache,target=/root/.npm \
    npm ci

FROM rust:1.77 AS builder
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo build --release
```

### Secret Mounts

Pass secrets at build time without baking them into layers:

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN=$(cat /run/secrets/npm_token) npm ci
```

```bash
docker build --secret id=npm_token,src=.npm_token .
```

## .dockerignore

Always include a `.dockerignore` to reduce build context:

```
.git
.gitignore
.github
.env*
node_modules
dist
build
*.md
docker-compose*.yml
Dockerfile*
.dockerignore
**/*.test.js
**/*.spec.js
coverage/
.vscode/
.idea/
```

## Security Patterns

### Non-Root Execution

```dockerfile
# Create a dedicated user and group
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

# Change ownership of application files
COPY --chown=appuser:appuser . /app

# Drop to non-root before running
USER appuser
```

### Base Image Selection

| Use Case | Base Image | Size | Security |
|----------|-----------|------|----------|
| Static binaries (Go, Rust) | `scratch` or `distroless/static` | ~2MB | Minimal attack surface |
| Binaries needing libc | `distroless/base` | ~20MB | No shell, no package manager |
| Apps needing OS packages | `*-slim` variants | ~80MB | Reduced package set |
| Build stages only | Full images (`bookworm`, `bullseye`) | ~300MB+ | Never ship to production |

### Vulnerability Scanning

```bash
# Docker Scout (built-in)
docker scout cves myapp:latest
docker scout recommendations myapp:latest

# Trivy
trivy image --severity HIGH,CRITICAL myapp:latest

# Grype
grype myapp:latest
```

Integrate scanning into CI — fail the build on HIGH or CRITICAL vulnerabilities.

## Compose Patterns

### Service Definition with Health Checks

```yaml
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: runtime
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgres://db:5432/app
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "1.0"

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: app
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  pgdata:

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Profiles for Conditional Services

```yaml
services:
  api:
    build: .
    ports: ["8080:8080"]

  db:
    image: postgres:16-alpine
    profiles: ["dev", "full"]

  redis:
    image: redis:7-alpine
    profiles: ["dev", "full"]

  prometheus:
    image: prom/prometheus:latest
    profiles: ["monitoring"]

  grafana:
    image: grafana/grafana:latest
    profiles: ["monitoring"]
```

```bash
docker compose --profile dev up        # api + db + redis
docker compose --profile monitoring up  # api + prometheus + grafana
docker compose --profile full --profile monitoring up  # everything
```

### Networking Isolation

```yaml
services:
  api:
    networks:
      - frontend
      - backend

  db:
    networks:
      - backend    # Not reachable from frontend

  nginx:
    networks:
      - frontend   # Cannot reach db directly

networks:
  frontend:
  backend:
```

## Multi-Platform Builds

```bash
# Create a multi-platform builder
docker buildx create --name multiarch --driver docker-container --use

# Build for multiple platforms and push
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag myorg/myapp:v1.2.3 \
  --push .
```

## Anti-Patterns

### Running as Root
Never run production containers as root. Containers share the host kernel — root inside the container is root on the host if the container escapes.

### Storing Secrets in Images
Secrets added via `COPY`, `ENV`, or `ARG` persist in image layers. Use `--mount=type=secret` for build-time secrets and runtime injection (environment variables, mounted files) for runtime secrets.

### Using `latest` Tag in Production
`latest` is mutable and non-deterministic. Always use immutable tags (semantic versions or SHA digests) for production deployments.

### Unbounded Log Output
Containers writing to stdout/stderr without log rotation can exhaust disk space. Configure the Docker logging driver with `max-size` and `max-file`:

```yaml
services:
  api:
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

### Installing Unnecessary Packages
Every additional package increases attack surface and image size. Use `--no-install-recommends` with apt, remove caches in the same `RUN` layer, and audit what is actually needed at runtime.
