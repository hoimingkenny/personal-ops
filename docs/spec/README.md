# Specifications and planning docs

Where product and build documentation lives.

## Canonical (use these when building)

| Doc | Purpose |
|-----|---------|
| [`CONTEXT.md`](../../CONTEXT.md) | Domain glossary and naming |
| [`docs/adr/`](../adr/README.md) | Locked decisions (scope, AWS, scheduling) |
| [`.scratch/vibe-trading-research-agent/spec.md`](../../.scratch/vibe-trading-research-agent/spec.md) | **Active build spec** — created by `/to-spec`; drives tickets and `/implement` |
| [`docs/spec/senior-skill-map.md`](./senior-skill-map.md) | Evidence map for making the repo read as senior backend/platform work |
| [`docs/spec/agent-harness.md`](./agent-harness.md) | Harness contract for bounded agents, tools, quality gates, evals, and replay |
| [`docs/ci-cd.md`](../ci-cd.md) | CI/CD and GitHub setup |
| [`docs/aws-demo-runbook.md`](../aws-demo-runbook.md) | Terraform apply → deploy → destroy |

When the active spec and an ADR disagree, **the ADR wins**.

## Removed

Earlier dashboard-era brainstorms were superseded. Decisions live in **ADRs** and **CONTEXT**; implementation detail will live in **`.scratch/vibe-trading-research-agent/spec.md`** after `/to-spec`.
