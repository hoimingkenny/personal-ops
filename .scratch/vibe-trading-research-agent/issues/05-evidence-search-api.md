# 05 — Evidence Search API

**What to build:** A source-backed evidence search API over ingested news and report evidence. A user or agent can search evidence, filter by metadata, and receive results with citation anchors suitable for later research artifacts.

**Blocked by:** 03 — Source Registry And News Ingestion; 04 — Report URL To Evidence Library.

**Status:** ready-for-agent

- [ ] Evidence from both news ingestion and report ingestion can be searched through a public API.
- [ ] Search uses PostgreSQL full-text search as the first retrieval backend.
- [ ] Results include source identity, source URL, title or document name, snippet, metadata, and citation anchor.
- [ ] Search can filter by source type or other available metadata.
- [ ] Search responses are stable enough for agents and tests to consume without parsing prose.
- [ ] Tests cover successful search, empty results, metadata filters, and citation anchor integrity.
