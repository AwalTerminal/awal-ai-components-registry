# Docker Build & Run

Run with docker CLI:
- `docker build -t myapp .` — build an image
- `docker build --no-cache -t myapp .` — build without layer cache
- `docker run --rm -p 8080:8080 myapp` — run a container
- `docker compose up -d` — start all services in detached mode
- `docker compose down -v` — stop services and remove volumes
- `docker compose logs -f service_name` — follow logs for a service
- `hadolint Dockerfile` — lint the Dockerfile
- `docker scout cves myapp:latest` — scan image for vulnerabilities
