# AWS demo: EventBridge schedules workflow creation

On AWS, **EventBridge → ECS Fargate RunTask** creates scheduled workflow runs, such as source ingestion and daily digest generation. Long-running ECS worker services execute workflow tasks asynchronously.

**Layout:** ECS API service (requests/status/SSE) + ECS worker service (task execution) + EventBridge-triggered scheduler task (creates due workflow runs). Same image, different runtime roles.

**Why:** Keeps scheduled work outside the API service, makes workflow creation observable, and provides a production-shaped cloud story without introducing SQS or Step Functions before the MVP needs them.

**Scale-up path:** If RDS task polling becomes limiting, move task dispatch to SQS. If workflow graphs become complex enough to justify managed orchestration, evaluate Step Functions.

**Local dev:** API and worker can run together under the `local` runtime role.

## App contract

| Runtime role | Behaviour |
|--------------|-----------|
| `api` | Web API, workflow status, digest/report reads, SSE progress |
| `worker` | No public web surface; polls durable tasks and executes pipeline/agent workers |
| `scheduler` | No web server; creates scheduled workflow runs and exits |

## Consequences

- `eventbridge.tf`, scheduler task definition, EventBridge IAM role
- Worker service needs database access, S3 artifact access, and model/API secrets
- API service should not perform expensive document processing or agent execution on request threads
