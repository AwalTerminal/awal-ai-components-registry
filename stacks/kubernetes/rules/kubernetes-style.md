# Kubernetes Style Rules

- Set resource `requests` and `limits` on every container — never deploy without them
- Use `app.kubernetes.io/` standard labels on all resources
- Use namespaces to isolate environments and teams — avoid putting everything in `default`
- Pin container image tags to specific versions or digests — never use `latest` in production
- Define `readinessProbe` and `livenessProbe` on all containers
- Use Kustomize or Helm for environment-specific configuration — avoid duplicating manifests
- Run `kubeval` or `kubeconform` to validate manifests before applying
- Store manifests in version control — use GitOps (ArgoCD, Flux) for production deployments
