# Web App Stack Rules

Use these shared rules for TypeScript, React, Next.js, Node.js APIs, and
full-stack web work.

- Prefer strict TypeScript contracts at API, component, service, and persistence
  boundaries.
- Keep server state, client state, and form state separate; use the project's
  existing data-fetching and state libraries first.
- Treat loading, optimistic updates, empty states, errors, pagination, and auth
  failures as part of the feature contract.
- Keep API responses consistent, for example `{ code, message, details }` for
  errors when the project has no stronger local convention.
- Validate external input at the boundary and avoid leaking transport or ORM
  details into UI code.
- Add focused tests around data fetching, mutations, permissions, and user-facing
  flows.
