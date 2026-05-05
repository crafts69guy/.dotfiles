# Medusa Stack Rules

Use these shared rules for Medusa backend, commerce adapters, storefronts, payment providers, and integrations.

- Treat backend wrapper contracts as the source of truth when an app owns wrapper endpoints.
- Keep SDK or transport details at the service boundary.
- Validate risky external response contracts before exposing them to feature code.
- Keep payment lifecycles backend-first: signing, verification, idempotency, reconciliation, and refunds belong on the backend.
- Preserve idempotency and observability around webhooks, retries, and concurrent payment events.
