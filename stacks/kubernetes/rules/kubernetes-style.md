# Kubernetes Style and Security Rules

## Labeling Conventions

- Apply the standard `app.kubernetes.io/` labels to every resource:
  - `app.kubernetes.io/name` — Application name
  - `app.kubernetes.io/instance` — Unique instance identifier
  - `app.kubernetes.io/version` — Application version
  - `app.kubernetes.io/component` — Component within the architecture (frontend, backend, database)
  - `app.kubernetes.io/part-of` — Higher-level application this belongs to
  - `app.kubernetes.io/managed-by` — Tool managing this resource (helm, kustomize, argocd)
- Use consistent label selectors in Services, Deployments, and NetworkPolicies
- Add team ownership labels: `team: platform`, `owner: api-team`
- Add cost allocation labels when using cloud-provider cost tools

## Namespace Organization

- Never deploy workloads to the `default` namespace
- Create namespaces per team, service boundary, or environment: `api-production`, `data-pipeline`, `monitoring`
- Apply ResourceQuotas and LimitRanges to every namespace
- Use namespace-scoped RBAC to restrict team access to their own namespaces
- Apply default NetworkPolicies (deny-all-ingress) at namespace creation

## Resource Management Rules

- Set `requests` and `limits` on every container — no exceptions
- Set `requests` based on observed steady-state usage (P50-P75)
- Set `limits` at 2-3x requests to handle spikes without OOMKill
- For critical workloads, set requests equal to limits (Guaranteed QoS)
- Never set CPU limits without CPU requests
- Never set memory limits lower than what the application actually needs — profile first
- Apply LimitRanges to catch containers deployed without resource specs

## Pod Security

- Enforce Pod Security Standards at the namespace level:
  ```yaml
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/audit: restricted
  ```
- Never run containers as root — set `runAsNonRoot: true` in the security context
- Never use privileged mode — set `privileged: false`
- Drop all capabilities and add only what is needed:
  ```yaml
  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
  ```
- Use read-only root filesystem where possible: `readOnlyRootFilesystem: true`
- Set `runAsUser` and `runAsGroup` to specific non-root UIDs
- Never mount the service account token unless the pod needs Kubernetes API access: `automountServiceAccountToken: false`

## Network Security

- Apply a default deny-all-ingress NetworkPolicy to every namespace
- Explicitly allow only required pod-to-pod communication paths
- Use TLS for all external-facing Ingress — enforce HTTPS redirects
- Use service mesh mTLS for internal service-to-service encryption when required
- Never expose services with `type: NodePort` in production — use Ingress or LoadBalancer with proper access controls
- Restrict egress traffic where feasible — prevent data exfiltration from compromised pods

## Secret Management

- Never store secrets in plain text in manifests committed to version control
- Use External Secrets Operator, Sealed Secrets, or HashiCorp Vault for production secrets
- Rotate secrets on a schedule — use operator-managed rotation where possible
- Mount secrets as files, not environment variables, for sensitive values (environment variables appear in `kubectl describe`)
- Restrict RBAC access to Secret resources — most service accounts should not be able to read secrets in other namespaces

## RBAC Rules

- Follow the principle of least privilege — grant only the permissions each workload or user needs
- Use Roles and RoleBindings (namespace-scoped) instead of ClusterRoles when possible
- Never bind ClusterRole `cluster-admin` to service accounts
- Audit RBAC bindings regularly — remove stale entries
- Use separate service accounts per workload — never share the `default` service account across services

## Image Policy

- Pin container images to specific version tags or SHA digests — never use `latest` or untagged images
- Pull images from a private registry with image pull secrets configured
- Use admission controllers (OPA Gatekeeper, Kyverno) to enforce image source policies
- Scan images for vulnerabilities in CI — reject images with CRITICAL findings

## Deployment Strategy

- Use rolling updates with `maxUnavailable: 0` and `maxSurge: 1` for zero-downtime deploys
- Define PodDisruptionBudgets for all production Deployments and StatefulSets
- Set `terminationGracePeriodSeconds` long enough for graceful shutdown (default 30s is often insufficient for connection draining)
- Configure preStop hooks when the application needs time to drain connections
- Always define both readiness and liveness probes — use startup probes for slow-starting apps

## Manifest Validation

- Run `kubeconform` or `kubeval` on all manifests in CI before applying
- Use `kube-linter` to check for best practice violations
- Validate Helm charts with `helm lint` and `helm template` before deploying
- Store all manifests in version control — use GitOps (ArgoCD, Flux) for production

## Observability Standards

- Export application metrics in Prometheus format on a `/metrics` endpoint
- Set up ServiceMonitors for automatic Prometheus scraping
- Define alerts for: pod restarts > 3 in 10 minutes, OOMKills, pending pods > 5 minutes, HPA at max replicas
- Aggregate logs to a centralized system — never rely on `kubectl logs` for production debugging
- Trace requests across services with distributed tracing (OpenTelemetry)
