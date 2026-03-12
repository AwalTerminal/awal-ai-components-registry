# Kubernetes Deploy & Debug

Run with kubectl:
- `kubectl apply -f manifests/` — apply all manifests in a directory
- `kubectl get pods -n my-namespace` — list pods in a namespace
- `kubectl logs -f deploy/my-app` — follow logs for a deployment
- `kubectl describe pod my-pod` — show detailed pod status and events
- `kubectl rollout status deploy/my-app` — watch a rollout
- `kubectl rollout undo deploy/my-app` — revert to previous version
- `helm upgrade --install my-release chart/` — deploy or upgrade a Helm chart
- `kubeconform -strict manifests/` — validate manifests against schemas
