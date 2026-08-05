# 05 — Skills And Tool Registry

## Goal

Make tool use explicit, typed, and logged.

## Scope

- Add agent/skill/tool definitions based on `docs/spec/agent-harness.md`.
- Implement typed tool-call logging.
- Add initial tools: `search_evidence`, `get_document_chunk`, `get_table`, `write_digest_artifact`, `verify_citation`.
- Enforce allowed tools per agent definition.

## Acceptance Criteria

- Tool calls record input/output hashes or redacted payloads, duration, errors, and versions.
- Disallowed tool calls fail deterministically.
- Tool definitions can be loaded from YAML fixtures or config.
- `ruff check .`, `mypy app`, and `pytest` pass.

## Senior Signal

Agents use controlled backend tools instead of hidden prompt-side effects.
