# Pipeline-triggered ECS deploy over GitOps for the AWS demo

The AWS demo uses **GitHub Actions to build, scan, push, and deploy** directly to ECS Fargate. We are not running ArgoCD or Flux for this environment.

**Why:** A pipeline-triggered deploy matches how many AWS-centric Spring Boot teams ship day-to-day — build JAR, containerise, push to ECR, update ECS service, gate on health. It is simpler to stand up alone, keeps the cloud story visible in one place (`.github/workflows/` + Terraform), and still demonstrates enterprise patterns: OIDC to IAM, SHA-tagged images, Trivy scan, Secrets Manager, readiness probes.

**Kubernetes path:** Local iteration uses **Helm on k3s/kind** (CronJob pollers, probes, ConfigMaps). Same container image; different orchestrator. GitOps is the scale-up pattern for that path, not the AWS demo default.

## Considered options

| Option | Use for | Rejected for AWS demo because |
|--------|---------|------------------------------|
| **Pipeline → ECS** (chosen) | AWS demo | — |
| **GitOps (ArgoCD + Helm)** | Multi-env K8s at scale | Extra moving parts (ArgoCD install, sync policies, drift) without adding AWS signal for a solo demo |
| **Manual deploy** | — | Does not demonstrate CI/CD |

## Scale-up pattern (document, do not build in v1)

When the runtime is Kubernetes and multiple environments need declarative sync:

1. CI builds and pushes the image to ECR (unchanged).
2. CI updates the **image tag in Helm values** (or a Kustomize overlay) and commits to a deploy repo — or uses ArgoCD Image Updater.
3. **ArgoCD** watches the deploy repo and syncs to the cluster.

Interview line: *"Demo uses pipeline deploy to ECS; at scale I'd keep the build/scan/push half and hand deploy to ArgoCD + Helm on EKS."*

## Consequences

- `.github/workflows/deploy-demo.yml` owns the AWS rollout; no ArgoCD manifests in v1.
- `deploy/helm/` targets local/k3s; `deploy/terraform/` targets AWS ECS + RDS + ECR.
- `docs/ci-cd.md` describes both the implemented pipeline and the GitOps upgrade path.
