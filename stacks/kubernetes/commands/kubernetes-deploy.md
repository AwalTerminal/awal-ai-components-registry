# Kubernetes Deploy, Debug, and Operations

## kubectl Core Operations

```bash
# Apply manifests from a directory
kubectl apply -f manifests/

# Apply with dry-run to preview changes
kubectl apply -f manifests/ --dry-run=server

# Apply with pruning (remove resources not in the manifest set)
kubectl apply -f manifests/ --prune -l app=myapp

# Delete resources from manifests
kubectl delete -f manifests/

# Get all resources in a namespace
kubectl get all -n production

# Get pods with extra detail (node, IP, status)
kubectl get pods -n production -o wide

# Get resources with custom columns
kubectl get pods -o custom-columns='NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName,RESTARTS:.status.containerStatuses[0].restartCount'

# Watch resources in real time
kubectl get pods -n production -w
```

## Deployment Management

```bash
# Rollout status — wait for deployment to complete
kubectl rollout status deploy/api -n production

# View rollout history
kubectl rollout history deploy/api -n production

# Rollback to the previous version
kubectl rollout undo deploy/api -n production

# Rollback to a specific revision
kubectl rollout undo deploy/api -n production --to-revision=3

# Restart all pods in a deployment (rolling restart)
kubectl rollout restart deploy/api -n production

# Scale a deployment
kubectl scale deploy/api -n production --replicas=5

# Pause and resume a rollout (for canary-style manual gating)
kubectl rollout pause deploy/api -n production
kubectl rollout resume deploy/api -n production
```

## Debugging

```bash
# Describe a pod (events, conditions, resource usage)
kubectl describe pod api-abc123 -n production

# View logs for a specific container
kubectl logs api-abc123 -c api -n production

# Follow logs with timestamps
kubectl logs -f --timestamps deploy/api -n production

# View logs from previous crashed container
kubectl logs api-abc123 -c api --previous -n production

# View logs from all pods matching a label
kubectl logs -l app=api -n production --all-containers

# Exec into a running container
kubectl exec -it api-abc123 -n production -- /bin/sh

# Run a debug container attached to a pod (ephemeral container)
kubectl debug -it api-abc123 -n production --image=busybox:1.36 --target=api

# Run a standalone debug pod in the same network namespace
kubectl run debug --rm -it --image=nicolaka/netshoot -n production -- /bin/bash

# Port-forward to a pod
kubectl port-forward pod/api-abc123 8080:8080 -n production

# Port-forward to a service
kubectl port-forward svc/api 8080:8080 -n production

# View resource consumption (requires metrics-server)
kubectl top pods -n production
kubectl top nodes

# View events in a namespace (sorted by time)
kubectl events -n production --sort-by='.lastTimestamp'

# Check why a pod is not scheduling
kubectl describe pod PENDING_POD -n production
# Look for: Insufficient cpu/memory, node selector mismatch, taint/toleration issues
```

## Helm Operations

```bash
# Add a chart repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Search for charts
helm search repo postgres

# Install a chart
helm install my-release bitnami/postgresql -n database --create-namespace -f values.yaml

# Upgrade a release
helm upgrade my-release bitnami/postgresql -n database -f values.yaml

# Install or upgrade (idempotent)
helm upgrade --install my-release bitnami/postgresql -n database -f values.yaml

# Diff before upgrade (requires helm-diff plugin)
helm diff upgrade my-release bitnami/postgresql -n database -f values.yaml

# Rollback to a previous revision
helm rollback my-release 2 -n database

# View release history
helm history my-release -n database

# List all releases
helm list -A

# Uninstall a release
helm uninstall my-release -n database

# Template locally (render manifests without deploying)
helm template my-release ./chart -f values.yaml > rendered.yaml

# Lint a chart
helm lint ./chart -f values.yaml

# Package a chart
helm package ./chart

# Show chart values documentation
helm show values bitnami/postgresql
```

## Kustomize Operations

```bash
# Build and preview kustomized manifests
kubectl kustomize overlays/production/

# Apply kustomized manifests
kubectl apply -k overlays/production/

# Diff kustomized manifests against live state
kubectl diff -k overlays/production/

# Directory structure
# base/
#   deployment.yaml
#   service.yaml
#   kustomization.yaml
# overlays/
#   production/
#     kustomization.yaml      # patches, replicas, images
#     resource-patch.yaml
#   staging/
#     kustomization.yaml
```

## Secret Operations

```bash
# Create a secret from literal values
kubectl create secret generic api-secrets \
  -n production \
  --from-literal=DATABASE_URL='postgres://...' \
  --from-literal=API_KEY='abc123'

# Create a secret from files
kubectl create secret generic tls-certs \
  -n production \
  --from-file=tls.crt=./cert.pem \
  --from-file=tls.key=./key.pem

# Create a TLS secret
kubectl create secret tls api-tls \
  -n production \
  --cert=./cert.pem \
  --key=./key.pem

# View a secret (base64 decoded)
kubectl get secret api-secrets -n production -o jsonpath='{.data.DATABASE_URL}' | base64 -d

# Seal a secret (Sealed Secrets)
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
kubectl apply -f sealed-secret.yaml
```

## Namespace and RBAC Management

```bash
# Create a namespace with labels
kubectl create namespace production
kubectl label namespace production \
  team=platform \
  pod-security.kubernetes.io/enforce=restricted

# View RBAC bindings in a namespace
kubectl get rolebindings -n production
kubectl describe rolebinding deployer-binding -n production

# Check if a user or service account can perform an action
kubectl auth can-i create deployments -n production --as=system:serviceaccount:production:deployer

# View all permissions for a service account
kubectl auth can-i --list --as=system:serviceaccount:production:deployer -n production
```

## Resource Cleanup

```bash
# Delete completed jobs
kubectl delete jobs --field-selector status.successful=1 -n production

# Delete evicted pods
kubectl get pods -n production --field-selector=status.phase=Failed -o name | xargs kubectl delete -n production

# Force delete a stuck pod
kubectl delete pod stuck-pod -n production --grace-period=0 --force

# Delete all resources in a namespace (DANGEROUS)
kubectl delete all --all -n staging
```

## Context and Cluster Management

```bash
# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context production-cluster

# Set default namespace for current context
kubectl config set-context --current --namespace=production

# View current context
kubectl config current-context

# Merge kubeconfig files
KUBECONFIG=~/.kube/config:new-cluster.yaml kubectl config view --flatten > merged.yaml
```

## CI/CD Deployment Pattern

```bash
# 1. Validate manifests
kubeconform -strict -kubernetes-version 1.29.0 manifests/
helm lint ./chart -f values.yaml

# 2. Diff against live state
kubectl diff -f manifests/ -n production

# 3. Apply changes
kubectl apply -f manifests/ -n production

# 4. Wait for rollout
kubectl rollout status deploy/api -n production --timeout=300s

# 5. Verify health
kubectl get pods -n production -l app=api
kubectl run smoke-test --rm -it --image=curlimages/curl -- curl -sf http://api.production:8080/health
```
