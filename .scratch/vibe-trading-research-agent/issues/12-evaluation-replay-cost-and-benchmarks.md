# 12 — Evaluation Replay Cost And Benchmarks

**What to build:** A measurable quality and performance layer for the research agent. A developer can run golden eval cases, replay stored workflows, inspect citation/numeric failures, and capture latency/cost benchmark evidence.

**Blocked by:** 11 — Research API And SSE Progress.

**Status:** ready-for-agent

- [ ] Golden eval cases can run against fixture sources and expected research outputs.
- [ ] Eval output includes pass/fail, score, missing citations, unsupported claims, numeric mismatches, latency, cost, and version metadata.
- [ ] A workflow can be replayed against stored source artifacts for reproducibility or regression comparison.
- [ ] Replay comparison reports changes in artifact output, citation coverage, numeric accuracy, unsupported claim rate, latency, cost, and failed tool calls.
- [ ] Benchmark commands produce initial latency results for search, artifact reads, workflow status, and at least one workflow path.
- [ ] Documentation records measured results honestly and uses them to justify deferring heavier infrastructure.
