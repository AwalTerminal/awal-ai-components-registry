# Docker Build, Run, and Operations

## Building Images

```bash
# Standard build
docker build -t myapp:latest .

# Build with a specific Dockerfile
docker build -f Dockerfile.prod -t myapp:prod .

# Build a specific stage from a multi-stage Dockerfile
docker build --target builder -t myapp:build-stage .

# Build with build arguments
docker build --build-arg NODE_ENV=production --build-arg VERSION=1.2.3 -t myapp:1.2.3 .

# Build with secret mounts (BuildKit)
DOCKER_BUILDKIT=1 docker build --secret id=npm_token,src=.npm_token -t myapp .

# Build with no cache (force full rebuild)
docker build --no-cache -t myapp .

# Build with inline cache export (speeds up CI builds)
docker build --cache-from myorg/myapp:cache --build-arg BUILDKIT_INLINE_CACHE=1 -t myapp .
```

## Multi-Platform Builds

```bash
# Create a multi-platform builder instance
docker buildx create --name multiarch --driver docker-container --use

# Build for multiple platforms and push to registry
docker buildx build --platform linux/amd64,linux/arm64 -t myorg/myapp:1.2.3 --push .

# Build for a specific platform locally
docker buildx build --platform linux/amd64 -t myapp:amd64 --load .

# Inspect the builder
docker buildx inspect multiarch
```

## Running Containers

```bash
# Run interactively with cleanup
docker run --rm -it myapp:latest /bin/sh

# Run detached with port mapping and name
docker run -d --name myapp -p 8080:8080 myapp:latest

# Run with resource limits
docker run -d --name myapp --memory=512m --cpus=1.0 myapp:latest

# Run with read-only filesystem and tmpfs for writable dirs
docker run -d --read-only --tmpfs /tmp --tmpfs /app/cache myapp:latest

# Run with dropped capabilities
docker run -d --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp:latest

# Run with environment variables from file
docker run -d --env-file .env myapp:latest

# Run with volume mount
docker run -d -v pgdata:/var/lib/postgresql/data postgres:16-alpine

# Run with bind mount (development)
docker run -d -v $(pwd)/src:/app/src myapp:latest
```

## Compose Operations

```bash
# Start all services in detached mode
docker compose up -d

# Start with build (rebuild images before starting)
docker compose up -d --build

# Start with specific profiles
docker compose --profile monitoring up -d

# Stop all services
docker compose down

# Stop and remove volumes (full cleanup)
docker compose down -v --remove-orphans

# Restart a single service
docker compose restart api

# Scale a service
docker compose up -d --scale worker=3

# View running services
docker compose ps

# Pull latest images for all services
docker compose pull
```

## Logs and Debugging

```bash
# Follow logs for all services
docker compose logs -f

# Follow logs for a specific service (last 100 lines)
docker compose logs -f --tail=100 api

# View logs with timestamps
docker compose logs -f -t api

# Execute a command in a running container
docker compose exec api /bin/sh

# Execute as root (debugging only)
docker compose exec -u root api /bin/sh

# Run a one-off command in a new container
docker compose run --rm api npm run migrate

# Inspect a container
docker inspect myapp

# View container resource usage
docker stats

# Copy files from container
docker cp myapp:/app/logs/error.log ./error.log

# View container processes
docker top myapp
```

## Image Management

```bash
# List local images
docker images

# List images with size details
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

# View image layer history and sizes
docker history myapp:latest

# Tag an image for a registry
docker tag myapp:latest myorg/myapp:1.2.3

# Push to a registry
docker push myorg/myapp:1.2.3

# Pull a specific image
docker pull myorg/myapp:1.2.3

# Save an image to a tar archive
docker save myapp:latest | gzip > myapp-latest.tar.gz

# Load an image from a tar archive
docker load < myapp-latest.tar.gz
```

## Security Scanning

```bash
# Docker Scout (built-in)
docker scout cves myapp:latest
docker scout recommendations myapp:latest
docker scout quickview myapp:latest

# Trivy
trivy image myapp:latest
trivy image --severity HIGH,CRITICAL --exit-code 1 myapp:latest

# Grype
grype myapp:latest
grype myapp:latest --fail-on high

# Hadolint (Dockerfile linting)
hadolint Dockerfile
hadolint --strict Dockerfile
```

## Cleanup and Pruning

```bash
# Remove all stopped containers
docker container prune -f

# Remove unused images (dangling only)
docker image prune -f

# Remove all unused images (including unreferenced)
docker image prune -a -f

# Remove unused volumes (CAUTION: deletes data)
docker volume prune -f

# Remove all unused resources (containers, images, networks, volumes)
docker system prune -a --volumes -f

# Check disk usage
docker system df
docker system df -v
```

## CI/CD Pipeline Pattern

```bash
# 1. Lint
hadolint Dockerfile

# 2. Build with cache
docker build \
  --cache-from myorg/myapp:cache \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t myorg/myapp:${GIT_SHA} \
  -t myorg/myapp:latest .

# 3. Scan
trivy image --exit-code 1 --severity HIGH,CRITICAL myorg/myapp:${GIT_SHA}

# 4. Test (run test stage or integration tests)
docker build --target tester .

# 5. Push
docker push myorg/myapp:${GIT_SHA}
docker push myorg/myapp:latest

# 6. Tag release (on tag push)
docker tag myorg/myapp:${GIT_SHA} myorg/myapp:${VERSION}
docker push myorg/myapp:${VERSION}
```

## Registry Operations

```bash
# Login to a registry
docker login registry.example.com

# Login to AWS ECR
aws ecr get-login-password | docker login --username AWS --password-stdin ACCOUNT.dkr.ecr.REGION.amazonaws.com

# Login to GCR
gcloud auth configure-docker

# List tags in a remote repository (using crane)
crane ls myorg/myapp

# Copy images between registries (using crane)
crane copy source-registry/myapp:v1 dest-registry/myapp:v1
```
