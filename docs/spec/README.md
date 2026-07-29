# Specifications and planning docs

Where product and build documentation lives.

## Canonical (use these when building)

| Doc | Purpose |
|-----|---------|
| [`CONTEXT.md`](../../CONTEXT.md) | Domain glossary and naming |
| [`docs/adr/`](../adr/README.md) | Locked decisions (scope, AWS, scheduling) |
| [`.scratch/personal-ops-os/spec.md`](../../.scratch/personal-ops-os/spec.md) | **Active build spec** — drives tickets and `/implement` |
| [`docs/ci-cd.md`](../ci-cd.md) | CI/CD and GitHub setup |
| [`docs/aws-demo-runbook.md`](../aws-demo-runbook.md) | Terraform apply → deploy → destroy |

When the active spec and an ADR disagree, **the ADR wins**.

## Removed

The original `personal-ops-dashboard-spec_1.md` (Dashboard-era brainstorm) was deleted — decisions live in **ADRs** and **CONTEXT**; implementation is driven by **[`.scratch/personal-ops-os/spec.md`](../../.scratch/personal-ops-os/spec.md)**.
