# 07 — Bounded Agent Runtime

**What to build:** A bounded ReAct-style agent runtime that can use only allowed tools, respects runtime budgets, and produces structured output or deterministic failure. This should make agent behavior observable and controlled rather than free-form.

**Blocked by:** 06 — Skills And Tool Execution Registry.

**Status:** ready-for-agent

- [ ] An agent definition declares allowed skills/tools, required output schema, max steps, max tool calls, timeout, and cost budget.
- [ ] A test agent can observe task input, call an allowed tool, observe the result, and produce structured output.
- [ ] The runtime rejects unknown tools or tools not allowed for the agent.
- [ ] The runtime stops with deterministic failure when max steps, max tool calls, timeout, or cost budget is exceeded.
- [ ] Agent execution records model/prompt/agent version metadata where applicable.
- [ ] Tests use fake model/tool adapters to verify runtime behavior without depending on live LLM calls.
