# 10 — Eval, Benchmark, And Cost Evidence

## Goal

Make quality, latency, and cost measurable.

## Scope

- Add golden eval cases for citation coverage, numeric accuracy, unsupported claims, and schema validity.
- Add k6 benchmarks for digest read, evidence search, and workflow status APIs.
- Track token/cost placeholders or real model usage when model API is wired.
- Capture query plans for retrieval and workflow task queries.

## Acceptance Criteria

- Eval command produces pass/fail metrics.
- Benchmark command reports P95/P99 and throughput.
- Docs separate measured facts from hypotheses.
- Redis/search infra is not added unless benchmark results justify it.

## Senior Signal

Optimization and quality claims are evidence-backed, not vibes-backed.
