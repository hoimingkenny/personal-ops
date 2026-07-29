# AWS demo: EventBridge schedules polls as ECS RunTask

On AWS, **EventBridge → ECS Fargate RunTask** runs connector polls — not in-process `@Scheduled` on the API service.

**Layout:** ECS Service (always-on API) + EventBridge rule → one-shot poller task (same image, `aws,poller` profile: poll, write snapshots, exit).

**Why:** Credibly mention EventBridge on CV; separates pull from serve; K8s equivalent = CronJobs (scope B).

**Local dev:** `@Scheduled` in `local` profile is fine.

## App contract

| Profile | Behaviour |
|---------|-----------|
| `aws` | Web API only |
| `aws,poller` | No web server; poll once on startup; exit 0 |

## Consequences

- `eventbridge.tf`, poller task definition, EventBridge IAM role
