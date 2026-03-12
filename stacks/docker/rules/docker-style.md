# Docker Style Rules

- Use multi-stage builds — final stage should use a minimal base (`alpine`, `distroless`, `scratch`)
- Pin base image tags to specific versions, not `latest`
- Run as non-root: add `USER` instruction before `CMD`/`ENTRYPOINT`
- Use `COPY` instead of `ADD` unless extracting a tar archive
- Combine `RUN` commands to minimize layers — clean package caches in the same `RUN`
- Use `HEALTHCHECK` in every production Dockerfile
- Add a `.dockerignore` file — exclude `.git`, `node_modules`, build artifacts
- Use `hadolint` to lint Dockerfiles — fix all warnings
