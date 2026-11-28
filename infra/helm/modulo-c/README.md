# Module C Helm values

This directory parameterizes the Module A service chart. It does not contain a chart and does not replace MPC-160.

Each service has one values file. `_common.yaml` holds the probes, security context, HPA behavior and rollout settings shared by every Module C service. Pass both files to the Module A chart:

```bash
helm template classroom-service <path-to-module-a-chart> \
  --namespace modulo-c \
  -f infra/helm/modulo-c/values/_common.yaml \
  -f infra/helm/modulo-c/values/classroom-service.yaml
```

Argo CD can use the same two files in `spec.source.helm.valueFiles`.

## Service matrix

| Service | Code | Level | `replicas_min` | `replicas_max` | CPU request / limit | Memory request / limit |
| --- | :-: | :-: | ---: | ---: | --- | --- |
| `classroom-service` | AUL | 1 | 3 | 12 | 250m / 1000m | 512Mi / 1Gi |
| `content-service` | CNT | 1 | 3 | 12 | 250m / 1000m | 512Mi / 1Gi |
| `assignment-service` | ASG | 1 | 3 | 12 | 250m / 1000m | 512Mi / 1Gi |
| `quiz-service` | CUE | 1 | 3 | 12 | 250m / 1000m | 512Mi / 1Gi |
| `grading-service` | GRD | 1 | 3 | 12 | 250m / 1000m | 512Mi / 1Gi |
| `attendance-service` | ATT | 1 | 3 | 12 | 250m / 1000m | 512Mi / 1Gi |
| `attendance-compliance-service` | ATC | 2 | 2 | 8 | 200m / 500m | 384Mi / 768Mi |
| `analytics-service` | ANL | 2 | 2 | 8 | 500m / 2000m | 1Gi / 2Gi |
| `reporting-service` | RPT | 2 | 2 | 8 | 250m / 1000m | 512Mi / 1Gi |
| `risk-service` | RSK | 2 | 2 | 8 | 500m / 2000m | 1Gi / 4Gi |

## What the values set

- `replicas_min` and `replicas_max` as the explicit contract from `CONTEXTO.md` section 4.3.
- `autoscaling.minReplicas` and `autoscaling.maxReplicas` with the same numbers, so the chart HPA and the explicit fields cannot drift.
- CPU and memory requests and limits per service. RSK gets more memory for inference.
- Liveness, readiness and startup probes on `/health` and `/ready`.
- A PodDisruptionBudget of 2 available pods for level 1 and 1 for level 2.
- Non-root execution, a read-only root filesystem, dropped capabilities and `RuntimeDefault` seccomp.
- The IRSA service account annotation `eks.amazonaws.com/role-arn`. Replace the account placeholder with the role ARN published at `/mentora/staging/modulo-c/services/<code>/role_arn`.
- The ECR image repository. Replace `REPLACE_WITH_ECR_REGISTRY` with the Module A registry output.

## Verification

Use the Module A chart and a test image to check the rendered objects:

```bash
helm template classroom-service <path-to-module-a-chart> \
  -f infra/helm/modulo-c/values/_common.yaml \
  -f infra/helm/modulo-c/values/classroom-service.yaml \
  | grep -E "replicas:|minReplicas:|maxReplicas:|readinessProbe:|livenessProbe:|kind: HorizontalPodAutoscaler"
```

With a cluster, the acceptance checks are:

```bash
kubectl -n modulo-c get deploy classroom-service -o jsonpath='{.spec.replicas}'
kubectl -n modulo-c get hpa classroom-service
kubectl -n modulo-c rollout undo deploy/classroom-service
```

The first command must return `3` for a level 1 service. The HPA must scale under synthetic load. The rollback must return to the previous ReplicaSet.

## Level rules

- Level 1: minimum 3 replicas, HPA up to 12, PodDisruptionBudget 2, last to degrade.
- Level 2: minimum 2 replicas, HPA up to 8, PodDisruptionBudget 1, can degrade first.

The values do not create secrets. The pods read their database and Valkey credentials from Secrets Manager through their IRSA role, and the database endpoints from SSM Parameter Store.
