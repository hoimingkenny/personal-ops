# 07 — Digest Agents And Quality Gates

## Goal

Generate source-backed financial digests through specialized agent workers.

## Scope

- Implement Classifier/Ranker Agent.
- Implement Brief Writer Agent.
- Implement Citation Verifier Agent.
- Implement Digest Composer.
- Add quality gates for schema validity, citation coverage, unsupported claims, and numeric claims.

## Acceptance Criteria

- Digest output includes source citations for supported claims.
- Unsupported or unverifiable claims block publish and mark artifact as `needs_review` or `quality_gate_failed`.
- Numeric claims are checked against extracted evidence when available.
- `ruff check .`, `mypy app`, and `pytest` pass.

## Out Of Scope

- Investment advice.
- Buy/sell/hold language.
