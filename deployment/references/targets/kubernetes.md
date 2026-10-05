# Target: Kubernetes

Whether to use Kubernetes: `decision-rules.md` §8. This file: which resources, how they
look, how the pipeline applies them, how to roll back.

## 1. Resource selection

Generate a resource only when its condition holds; list each omission with its reason.

| Resource | Condition |
|---|---|
| Deployment | long-running process (Web API, Worker, server-side Frontend) |
| Service (ClusterIP) | the container listens on a port. Worker without a port: none |
| ConfigMap | non-secret configuration differs from image defaults |
| Secret reference | the app needs a secret; reference only (`secrets.md` §2) |
| startupProbe + readinessProbe | HTTP health endpoint exists or is added under Hard Rule 9 |
| livenessProbe | only on request or a known hang risk; never the same check as readiness |
| resources.requests / limits | values from this unit's existing manifests or the user; otherwise `Unknown` and left out (§2) - never invented, never copied from another service as if it were evidence |
| Ingress | external exposure required **and** ingress class / host known |
| HPA | autoscaling requested or CONFIRMED needed, and CPU/memory requests are set |
| CronJob | Scheduled Job unit, or a scheduled task that today runs inside the API |
| PVC / StatefulSet | not generated in v1; persistent state -> Finding / Unknown |

## 2. Operational values

General rule: `decision-rules.md` §9. Kubernetes specifics:

| Value | Source, in order | No evidence |
|---|---|---|
| `replicas` | existing manifest / overlay -> user -> `1` only when CONFIRMED that one instance is enough and there is no HA requirement | HA required but count undefined -> `Unknown` (`Replicas: Unknown - HA is required, minimum replica count is not defined`); nothing known about HA -> `Unknown`. Never 2 / 3 by convention |
| `containerPort` | existing Deployment -> Dockerfile `EXPOSE` / image `ASPNETCORE_HTTP_PORTS` -> app config & code -> existing compose -> user (.NET sources: `stacks/dotnet.md` §1) | `Unknown` -> Gate 7 (probes and Service depend on it) |
| Service `port` | existing Service -> consumers' configuration / Ingress -> user | `Unknown` -> Gate 7; the question may offer "same as containerPort" as an option, never pre-filled |
| Service `targetPort` | the containerPort (or its name) | follows containerPort |
| `resources` | existing manifest -> user | omitted, listed `Unknown`; HPA then not generated |
| HPA min / max / target | user -> existing HPA | HPA not generated |
| namespace | existing overlays / CI variables -> user | fail-closed variable (`NAMESPACE`) |
| Ingress host / class | existing Ingress -> user | Ingress not generated |

Per-environment unknowns (`replicas`, `namespace`) may be fail-closed placeholders
substituted by the deploy job (§4); file-shaping unknowns (ports) gate.

## 3. Deployment shape

> **EXAMPLE ONLY - not a default.** `<...>` marks values that come from §2 evidence.
> Never fill them with the numbers a convention suggests.

```yaml
spec:
  replicas: <§2: evidence | ${REPLICAS} fail-closed placeholder>
  revisionHistoryLimit: 10
  strategy:
    type: RollingUpdate
    rollingUpdate: { maxSurge: 1, maxUnavailable: 0 }
  selector: { matchLabels: { app: <name> } }
  template:
    metadata: { labels: { app: <name> } }
    spec:
      terminationGracePeriodSeconds: 30
      containers:
        - name: <name>
          image: ${IMAGE}                 # or the repository's placeholder style
          ports: [{ name: http, containerPort: <§2 containerPort> }]
          envFrom:
            - configMapRef: { name: <name>-config }
          env:
            - name: <SECRET-BACKED SETTING, e.g. ConnectionStrings__Default>
              valueFrom: { secretKeyRef: { name: <secret name>, key: <key> } }
          startupProbe:   { httpGet: { path: <health path>, port: http }, periodSeconds: 5, failureThreshold: 30 }
          readinessProbe: { httpGet: { path: <health path>, port: http }, periodSeconds: 5, failureThreshold: 3 }
```

- Generic defaults in this shape - RollingUpdate `maxSurge: 1` / `maxUnavailable: 0`,
  probe timing, `revisionHistoryLimit`, `terminationGracePeriodSeconds` matching the
  host's shutdown timeout - are allowed and stated as `INFERRED` (`decision-rules.md`
  §9). Existing values always win.
- `Recreate` only when two versions must not run together (e.g. a singleton consumer
  without locking); the reason goes in the Assessment.
- Labels: one `app: <name>` label shared by Deployment selector, Pod template and
  Service selector; keep the repository's label scheme if it has one.
- Name the container port (`http`) and point probes and the Service `targetPort` at
  the name, so the number lives in one place.

## 4. Layout

| Situation | Layout |
|---|---|
| Existing manifests | keep their layout and placeholder style |
| One environment | plain manifests in `k8s/` (or `kubernetes/`) |
| ≥2 environments (existing or requested) | Kustomize `k8s/base/` + `k8s/overlays/<env>/` |

Kustomize overlays carry per-environment namespace, replicas, ConfigMap values
(`configMapGenerator` with `envs:`; keep `disableNameSuffixHash: true` only if the
repository already uses it) and image tag (`images:` entry). The base never contains
environment values.

Adding an environment to an existing overlay set: copy the nearest overlay and change
only what differs (namespace, config values). Values kept from the sibling (e.g. its
replicas) are stated as `INFERRED: copied from <env>`; values that must differ and
have no evidence follow §2.

## 5. Applying from the pipeline

Everything in this section is written **into the deploy job**; none of it is run by the
skill (`validation.md` §3).

Image substitution - follow the repository; new setups use one of:

- plain: `envsubst '$IMAGE' < k8s/deployment.yaml | kubectl apply -n <ns> -f -`
  (explicit variable list so other `$` survive)
- Kustomize: `kustomize edit set image <name>=$IMAGE_NAME:$IMAGE_TAG` in the job's
  checkout of the overlay (needs the `kustomize` binary in the deploy image; not
  committed back), then `kubectl apply -k k8s/overlays/<env>`

Fail-closed placeholders (§2) are checked before substitution and added to the
`envsubst` variable list:

```bash
: "${REPLICAS:?REPLICAS must be set for this environment}"
```

Then always:

```bash
kubectl rollout status deployment/<name> -n <ns> --timeout=300s
```

Non-zero exit fails the job. CronJobs and Deployments in the same unit get the same
image tag in the same job. CI never deletes Pods or Deployments to force an update.

## 6. CronJob

```yaml
spec:
  schedule: "<cron>"                 # from the repository / user; timezone stated
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      backoffLimit: 3
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: <job>
              image: ${IMAGE}
              args: [<worker command>]
```

A CronJob that starts the whole Web API to call its own localhost endpoint is recorded
as a Finding (prefer a worker / command entry point) but kept if it already exists.

## 7. Rollback

```bash
kubectl rollout history deployment/<name> -n <ns>
kubectl get deployment <name> -n <ns> -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl rollout undo deployment/<name> -n <ns> [--to-revision=<n>]
kubectl rollout status deployment/<name> -n <ns>
```

Preferred: re-run the previous good commit's deploy job, so manifests, ConfigMap and
image return together. `rollout undo` reverts only the Pod template - note that a
ConfigMap changed in the same deploy is not reverted by it. CronJobs have no undo:
re-apply with the previous image tag.
