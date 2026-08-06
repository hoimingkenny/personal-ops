# Agent harness

The agent harness is the control and validation layer around Vibe Trading Research Agent workflows. It makes agent behaviour bounded, observable, replayable, and safe to publish.

The harness is not a model wrapper. It owns the contracts that turn LLM calls into backend infrastructure:

- agent capability definitions
- skill and tool permissions
- bounded ReAct runtime limits
- typed input/output schemas
- quality gates
- eval cases
- replay comparisons
- publish rules
- cost and latency budgets

## Harness contract

Each agent has a versioned capability definition. YAML is the preferred authoring format; the runtime may load it into database tables later.

```yaml
agent: BriefWriterAgent
version: v1
description: Writes digest sections from selected source-backed evidence.
model_policy:
  default_model: ${VIBE_TRADING_DEFAULT_MODEL}
  fallback_model: ${VIBE_TRADING_FALLBACK_MODEL}
runtime_limits:
  max_react_steps: 6
  max_tool_calls: 6
  max_latency_ms: 20000
  max_cost_usd: 0.08
allowed_skills:
  - summarize_evidence
  - compare_claims
  - write_digest_section
allowed_tools:
  - search_evidence
  - get_document_chunk
  - get_table
required_output_schema: digest_section.v1
quality_gates:
  - citation_coverage
  - unsupported_claim_check
  - schema_validity
```

## Skills and tools

**Agent** decides what to do within limits.

**Skill** is a reusable capability with schemas and quality expectations.

**Tool** performs actual IO or deterministic backend work.

Example:

```yaml
skill: citation_verify
version: v1
input_schema: citation_verify_request.v1
output_schema: citation_verify_result.v1
tools:
  - get_document_chunk
  - compare_claim_to_source
quality_gates:
  - numeric_claims_verified
  - unsupported_claim_check
```

Tool calls must be logged with:

- workflow run id
- task id
- agent name and version
- skill name and version when applicable
- tool name and version
- input hash or redacted input
- output hash or redacted output
- duration
- error
- retry count
- prompt/model version when applicable
- token usage and cost when applicable

## Bounded ReAct

Agents may use a controlled Think-Act-Observe loop:

```text
observe task input
→ choose allowed tool
→ observe tool result
→ choose next allowed step
→ produce structured output
```

The harness must enforce:

- max steps
- max tool calls
- allowed tools only
- per-agent timeout
- workflow-level timeout
- per-agent cost budget
- workflow-level cost budget
- structured output schema
- deterministic failure state when limits are exceeded

No agent may call arbitrary tools or continue unbounded loops.

## Quality gates

Quality gates run before a digest or report brief is published.

MVP gates:

| Gate | Purpose |
|------|---------|
| `schema_validity` | Output matches the required JSON/Markdown artifact schema. |
| `citation_coverage` | Claims that require support have source citations. |
| `unsupported_claim_check` | Generated claims are supported by cited evidence. |
| `numeric_claims_verified` | Numeric claims match extracted source evidence within explicit tolerance. |
| `cost_budget` | Workflow and agent costs stay within configured budget. |
| `latency_budget` | Workflow and agent runtimes stay within configured budget. |

Recommended initial publish policy:

```text
publish only if schema_validity passes
and citation_coverage >= 0.95
and unsupported_claim_check has zero high-severity failures
and numeric_claims_verified has zero high-severity failures
otherwise mark the artifact as needs_review
```

## Evaluation harness

The eval harness uses golden cases checked into the repo.

Each case should include:

- source documents or stable fixture excerpts
- input request
- expected artifact type
- required citations
- expected numeric values when applicable
- allowed tolerance
- expected failure cases

Example:

```yaml
case: revenue_numeric_claim_v1
input:
  company: ExampleCo
  report: FY2025 annual report
  question: Summarize revenue performance.
expect:
  required_values:
    - metric: revenue
      period: FY2025
      value: 1234000000
      currency: USD
      tolerance: 0
  required_citations:
    - document: exampleco-fy2025-annual-report
      page: 42
```

Eval output should include:

- pass/fail
- score
- failed claims
- missing citations
- numeric mismatches
- latency
- token cost
- model/prompt/agent versions

## Replay harness

A workflow run should be replayable against the same stored source artifacts.

Replay modes:

- same agent/prompt/model version for reproducibility checks
- new agent/prompt/model version for regression comparison
- retrieval configuration change for search quality comparison

Compare:

- digest diff
- citation coverage
- numeric accuracy
- unsupported claim rate
- latency
- cost
- failed tool calls

## Publish states

Digest artifacts move through explicit states:

```text
draft
→ quality_gate_failed
→ needs_review
→ approved
→ published
```

MVP may skip manual review UI, but the backend state model should leave room for human review.

## Out of scope for MVP

- Mem0 as a memory backend.
- Milvus/OpenSearch before retrieval benchmarks justify them.
- Free-form swarm behaviour.
- Custom model training.
- Multimodal extraction unless text/PDF extraction cannot handle the selected fixtures.
