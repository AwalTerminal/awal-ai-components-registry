# Kubernetes Patterns

## Resource Management

### Requests and Limits

Every container must declare resource requests and limits. Requests guarantee scheduling; limits prevent runaway consumption:

```yaml
resources:
  requests:
    cpu: 100m       # 0.1 CPU cores — scheduler guarantees this
    memory: 128Mi   # Scheduler guarantees this memory
  limits:
    cpu: 500m       # Hard cap — throttled above this
    memory: 256Mi   # Hard cap — OOMKilled above this
```

### QoS Classes

Kubernetes assigns QoS classes based on resource declarations:

| QoS Class | Condition | Eviction Priority |
|-----------|-----------|-------------------|
| **Guaranteed** | requests == limits for all containers | Last to be evicted |
| **Burstable** | At least one request set, requests != limits | Middle priority |
| **BestEffort** | No requests or limits set | First to be evicted |

Set `Guaranteed` QoS for critical workloads by making requests equal to limits:

```yaml
resources:
  requests:
    cpu: 500m
    memory: 256Mi
  limits:
    cpu: 500m      # Same as request = Guaranteed QoS
    memory: 256Mi  # Same as request = Guaranteed QoS
```

### LimitRange and ResourceQuota

Enforce defaults and caps at the namespace level:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
spec:
  limits:
    - type: Container
      default:
        cpu: 200m
        memory: 256Mi
      defaultRequest:
        cpu: 100m
        memory: 128Mi
      max:
        cpu: "2"
        memory: 2Gi
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    pods: "50"
```

## Probes and Lifecycle

### Probe Configuration

```yaml
containers:
  - name: api
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
      timeoutSeconds: 3
      failureThreshold: 3
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 2
      failureThreshold: 3
    startupProbe:
      httpGet:
        path: /healthz
        port: 8080
      periodSeconds: 5
      failureThreshold: 30   # 30 * 5s = 150s max startup time
```

- **Liveness:** Restarts the container if it fails. Use for deadlock detection. Do not check dependencies.
- **Readiness:** Removes the pod from service endpoints. Use when the app cannot serve traffic temporarily.
- **Startup:** Disables liveness/readiness until the app starts. Use for slow-starting applications.

## Workload Patterns

### Sidecar Container

```yaml
spec:
  containers:
    - name: app
      image: myapp:1.0
      ports:
        - containerPort: 8080
    - name: log-shipper
      image: fluent-bit:latest
      volumeMounts:
        - name: app-logs
          mountPath: /var/log/app
  volumes:
    - name: app-logs
      emptyDir: {}
```

### Init Container

Run setup tasks before the main container starts:

```yaml
spec:
  initContainers:
    - name: wait-for-db
      image: busybox:1.36
      command: ["sh", "-c", "until nc -z db-service 5432; do sleep 2; done"]
    - name: run-migrations
      image: myapp:1.0
      command: ["./migrate", "up"]
  containers:
    - name: app
      image: myapp:1.0
```

### CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: db-backup
spec:
  schedule: "0 2 * * *"    # Daily at 2 AM
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      backupLimit: 1
      activeDeadlineSeconds: 3600
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: backup
              image: backup-tool:1.0
              resources:
                requests:
                  cpu: 100m
                  memory: 256Mi
                limits:
                  cpu: 500m
                  memory: 512Mi
```

## Autoscaling and Availability

### Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 25
          periodSeconds: 60
```

### Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-pdb
spec:
  minAvailable: 2     # Or use maxUnavailable: 1
  selector:
    matchLabels:
      app: api
```

### Topology Spread

Distribute pods evenly across failure domains:

```yaml
spec:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchLabels:
          app: api
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app: api
```

## Networking

### Network Policies

Default deny all ingress, then allow specific traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-from-frontend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### Ingress with TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - api.example.com
      secretName: api-tls
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api
                port:
                  number: 8080
```

## Secret Management

### External Secrets Operator

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: api-secrets
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: api-secrets
    creationPolicy: Owner
  data:
    - secretKey: DATABASE_URL
      remoteRef:
        key: production/api/database-url
    - secretKey: API_KEY
      remoteRef:
        key: production/api/api-key
```

### Sealed Secrets

```bash
# Encrypt a secret with the cluster's public key
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
# The sealed secret is safe to commit to version control
kubectl apply -f sealed-secret.yaml
```

## Helm Chart Patterns

### values.yaml Structure

```yaml
replicaCount: 3

image:
  repository: myorg/myapp
  tag: "1.2.3"
  pullPolicy: IfNotPresent

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilization: 70

ingress:
  enabled: true
  host: api.example.com
  tls: true

env:
  LOG_LEVEL: info
  PORT: "8080"
```

### Template Patterns

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  template:
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

## Anti-Patterns

### No Resource Limits
Pods without limits can consume all node resources, causing cascading evictions. Always set both requests and limits.

### Privileged Containers
Never run containers in privileged mode. Use specific capabilities (`NET_BIND_SERVICE`, `SYS_PTRACE`) only when absolutely necessary.

### Default Namespace
Never deploy workloads to the `default` namespace. Create dedicated namespaces per team or service boundary.

### No Probes
Without readiness probes, traffic routes to pods that are not ready. Without liveness probes, deadlocked pods are never restarted.

### Latest Tag
Using `latest` or no tag means Kubernetes cannot detect image changes, and rollbacks become impossible. Always use immutable version tags or digests.

### No PDB
Without a PodDisruptionBudget, node drains and cluster upgrades can take down all replicas simultaneously.
