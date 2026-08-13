# 02 — Secret Provider And Vault Foundation

**What to build:** A pluggable secret provider foundation with HashiCorp Vault prioritized as a first-class runtime option. A developer can run the app with local environment secrets, understand how Vault will supply runtime secrets, and verify that deployable roles fail clearly when required secrets are missing.

**Blocked by:** 01 — FastAPI Spine And Local Runtime.

**Status:** ready-for-agent

- [ ] The app reads sensitive runtime values through a `SecretProvider` boundary instead of direct environment reads in application modules.
- [ ] A local environment provider supports developer defaults for local-only runs.
- [ ] A Vault provider contract is represented with configuration for Vault address, auth method placeholder, secret mount/path, and secret keys.
- [ ] Database URL resolution uses the secret provider boundary and distinguishes local optional database config from deployable required database config.
- [ ] Missing, unauthorized, or malformed secrets fail with explicit startup/readiness errors.
- [ ] Tests cover local provider success, missing deployable secrets, malformed secret payloads, and Vault client boundary behavior without requiring a live Vault server.
- [ ] Documentation explains the MVP secret flow and why Vault is prioritized before workflow/orchestration work.
