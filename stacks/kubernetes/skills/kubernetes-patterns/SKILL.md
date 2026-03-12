# Kubernetes Patterns

## Workload Design
- Use Deployments for stateless apps, StatefulSets for stateful workloads
- Set resource `requests` and `limits` on every container — prevent noisy neighbors
- Use `readinessProbe` and `livenessProbe` on all containers — configure appropriate thresholds
- Use `PodDisruptionBudget` to maintain availability during voluntary disruptions
- Use `topologySpreadConstraints` or anti-affinity for high-availability scheduling

## Configuration and Secrets
- Use ConfigMaps for non-sensitive configuration, Secrets for credentials
- Mount configuration as files rather than environment variables for large configs
- Use external secret managers (Vault, Sealed Secrets, External Secrets Operator) in production
- Never store secrets in plain text in manifests committed to version control

## Networking
- Use Services (`ClusterIP`) for internal communication between pods
- Use Ingress or Gateway API for external HTTP/HTTPS traffic
- Define NetworkPolicies to restrict pod-to-pod communication — deny by default
- Use headless services for StatefulSets that need stable DNS names

## Deployment Strategies
- Use rolling updates with `maxUnavailable: 0` and `maxSurge: 1` for zero-downtime deploys
- Use `kubectl rollout undo` to quickly revert bad deployments
- Use Helm or Kustomize for templating and environment-specific overlays
- Label all resources with `app.kubernetes.io/` standard labels

## Observability
- Export metrics in Prometheus format — use ServiceMonitors for auto-discovery
- Aggregate logs with a DaemonSet-based collector (Fluentd, Vector)
- Set up alerts for pod restarts, OOMKills, and pending pods
- Use `kubectl describe` and `kubectl logs` as first-line debugging tools
