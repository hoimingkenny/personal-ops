# 04 — Evidence And Retrieval Memory

## Goal

Build the source-backed retrieval memory agents will use.

## Scope

- Add evidence tables for documents, chunks, citations, tables, and extracted metadata.
- Add PostgreSQL full-text search over chunks.
- Add metadata filters for source, document type, company/name, and time.
- Add retrieval API/service for top-K evidence search.

## Acceptance Criteria

- Chunks keep citation anchors back to document/page/section/URL when available.
- Search returns ranked evidence with source metadata.
- Retrieval latency is covered by integration tests and basic timing logs.
- `ruff check .`, `mypy app`, and `pytest` pass.

## Out Of Scope

- pgvector, Milvus, OpenSearch.
- Ranking model training.
