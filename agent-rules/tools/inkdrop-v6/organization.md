# Inkdrop v6 Organization Rules

Use these rules when choosing notebooks, tags, statuses, or note granularity.

## Organization

- Choose notebooks by durable domain or project, not by temporary task.
- Use index notes as navigation hubs, for example `Index - Payments Architecture`, `Index - VN Pay`, or `Mobile Architecture Index`.
- Keep notes atomic: concept, implementation, ADR, checklist, incident, case study, glossary, index.
- Use tags for cross-cutting retrieval instead of duplicating notes across notebooks.
- Prefer existing lowercase tags. Create a tag only when the concept is durable and missing.

## Status Defaults

- `active`: living notes, active checklists, ongoing research, current project references.
- `completed`: finished task notes or closed research.
- `dropped`: abandoned work preserved for context.
- `none`: stable references or index notes that should not behave like tasks.

## Body Hygiene

- Do not duplicate the Inkdrop title as a body H1 for new notes unless matching a legacy notebook convention.
- Do not add `Tags: #...` lines to bodies; use native Inkdrop tags.
- Keep bodies concise and structured for retrieval.
- Use short tables only when they improve scanning.
