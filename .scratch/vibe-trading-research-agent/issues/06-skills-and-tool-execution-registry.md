# 06 — Skills And Tool Execution Registry

**What to build:** A typed skills/tools layer that lets agents call backend capabilities safely. A tool such as evidence search or chunk lookup can be invoked through a registered contract, and every call is logged with enough context to debug behavior, cost, and failures.

**Blocked by:** 05 — Evidence Search API.

**Status:** ready-for-agent

- [ ] Skills and tools have versioned definitions with explicit input and output schemas.
- [ ] Evidence search and document chunk lookup are exposed as registered tools.
- [ ] Tool execution validates inputs and outputs against the registered contract.
- [ ] Tool calls are logged with workflow run, task, tool name/version, input/output hash or redacted payload, duration, error, retry count, and cost fields when available.
- [ ] Unauthorized or unknown tools fail deterministically.
- [ ] Tests prove successful tool execution, validation failure, unknown tool failure, and logging behavior.
