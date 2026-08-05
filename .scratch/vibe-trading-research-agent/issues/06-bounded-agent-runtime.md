# 06 — Bounded Agent Runtime

## Goal

Implement a controlled agent loop with runtime limits.

## Scope

- Implement bounded ReAct execution: observe, choose tool, observe result, produce structured output.
- Enforce max steps, max tool calls, timeout, cost budget placeholder, and output schema.
- Store agent runs with model/prompt/agent version metadata.
- Add fake model adapter tests before wiring any real model API.

## Acceptance Criteria

- Agent execution stops at configured limits.
- Structured outputs are schema-validated.
- Tool-call attempts are logged.
- Failures produce explicit workflow/task states.
- `ruff check .`, `mypy app`, and `pytest` pass.

## Out Of Scope

- Model fine-tuning.
- Free-form autonomous swarm.
