# AWS demo: pipeline deploy over GitOps

The AWS demo uses **GitHub Actions to build, scan, push, and deploy** directly to ECS Fargate — not ArgoCD or Flux.

**Why:** Matches day-to-day AWS-centric Spring Boot shipping; keeps the story in `.github/workflows/` + Terraform; still shows OIDC, SHA-tagged images, Trivy, Secrets Manager, readiness probes.

**Kubernetes path:** Helm on k3s/kind locally; GitOps (ArgoCD) documented as scale-up when runtime is EKS/multi-env — CI build/scan/push unchanged, deploy handoff to ArgoCD sync.

**Interview line:** *"Demo uses pipeline deploy to ECS; at scale I'd hand deploy to ArgoCD + Helm on EKS."*

## Consequences

- `deploy-demo.yml` owns AWS rollout; no ArgoCD in v1.
- `deploy/helm/` → local K8s; `deploy/terraform/` → AWS.
