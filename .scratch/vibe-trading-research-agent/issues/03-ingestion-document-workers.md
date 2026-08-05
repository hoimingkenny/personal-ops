# 03 — Ingestion And Document Workers

## Goal

Fetch financial news feeds and user-provided report/PDF URLs into durable artifacts.

## Scope

- Implement source ingestion worker for RSS/news feeds.
- Implement report/PDF URL ingestion worker.
- Store raw artifacts in the local filesystem for local development and S3 for AWS runtime roles.
- Track source URL, fetched timestamp, content hash, and idempotency key.
- Add basic text extraction and chunking for HTML/text PDFs.

## Acceptance Criteria

- Re-running the same ingestion job does not duplicate documents.
- Raw artifact and extracted text metadata are persisted.
- Failed fetches produce task failure events with retry metadata.
- `ruff check .`, `mypy app`, and `pytest` pass.

## Out Of Scope

- Full SEC/HKEX crawler.
- Paid data providers.
- Multimodal scanned PDF extraction.
