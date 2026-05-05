---
name: inkdrop-note-taking
description: Use when the user wants Codex to research, synthesize, create, update, organize, or maintain technical notes with Inkdrop MCP; applies to architecture notes, learning notes, project design notes, decision records, checklists, glossary entries, and cross-linked knowledge systems.
---

# Inkdrop Note Taking

Use Inkdrop as the persistent knowledge base and treat the user as a technical collaborator. Optimize for durable, searchable, cross-linked notes that can be reused in future design and implementation work.

## Workflow

1. Ground the work before writing: inspect existing Inkdrop notebooks/notes/tags and read any provided source material, repo files, or draft markdown.
2. Clarify only high-impact choices: target notebook, audience, note granularity, link style, tag taxonomy, and whether to create or update notes.
3. Produce a concise proposed note structure when the task is broad or ambiguous.
4. Create or update notes only after the structure and conventions are clear.
5. Verify the result with Inkdrop reads/searches and report created/updated note titles, note IDs, and any unresolved manual actions.

## Inkdrop MCP Rules

- Start with the narrowest MCP discovery that can answer the question. Use `search_notes` with qualifiers or `list_notes` with `bookId`/`limit` before reading full note bodies.
- Use `list_notebooks` only when the target notebook is unknown, and use `list_tags` only when assigning or auditing native tags.
- Treat `search_notes` and `list_notes` results as previews; they contain truncated bodies. Call `read_note` only for notes being edited, index notes being updated, or the top few related notes needed for context.
- Never create a duplicate note without first searching by title or checking the target notebook.
- Use a readable Inkdrop note title that matches the note's H1-style title pattern, for example `Startup / Bootstrap Sequence`, not a lowercase slug like `startup-bootstrap-sequence`.
- Do not duplicate the note title inside the note body as a Markdown H1. The Inkdrop title is the note title.
- Do not include a `Tags: #...` line in the note body. Use Inkdrop native tags through the MCP `tags` field instead.
- Set new notes to `active` status by default unless the user asks for another status or the note is explicitly archival/reference-only.
- Use `create_note` for new notes, `update_note` for whole-note replacements, and `patch_note` only after reading the note and identifying one exact replacement string.
- Use `create_tag` only when an intended tag is missing; prefer existing lowercase tags.
- Treat notebook creation, deletion, rename, reorder, and UI-only behavior as user-assisted manual actions unless the current MCP exposes a safe tool for them.

## Note Design Principles

- Make notes atomic: one note should capture one clear concept, pattern, decision, checklist, or example.
- Separate concept/design notes from implementation/code notes.
- Prefer links over duplicated explanation.
- Keep note bodies concise enough to scan, but include concrete rules, trade-offs, and related links.
- Use reusable index notes for navigation rather than deep notebook nesting.
- Preserve source context and mark uncertain claims as assumptions until verified.

## Architecture Brain Workflow

When working with the Mobile Architecture notebook, treat it as an architecture operating system, not just a note archive. Start from `Mobile Architecture Index`, `Review Map`, and `Architecture Brain / Operating System` when the user asks for mobile architecture research, design, review, project kickoff, ADRs, or production learning.

Classify every note-taking task before writing:

- Concept: reusable design-level knowledge.
- Implementation: reusable code-level recipe, separate from concept notes.
- ADR: high-risk decision with alternatives, consequences, and revisit trigger.
- Checklist: repeatable review or release gate.
- Case study: generalized lesson from real project work.
- Incident learning: production or release failure that should sharpen the notebook.
- Glossary: stable terminology.
- Index/update: navigation or cross-reference maintenance.

After architecture reviews, project kickoffs, releases, incidents, or repeated PR feedback, run the feedback loop:

1. Identify what changed: decision, failure mode, repeated question, implementation recipe, or unclear term.
2. Decide which artifact should be updated: ADR, checklist, pattern, anti-pattern, implementation note, case study, incident learning, glossary, or index.
3. Preserve evergreen vs project-specific separation. Keep project-specific constraints in project notebooks and link back to evergreen architecture notes.
4. Add native Inkdrop links from the new or updated note to related system notes.
5. If a decision is still unresolved, add or update `Architecture Brain / Open Questions Register` instead of hiding the uncertainty.

Create an ADR when a decision affects module boundaries, auth/session behavior, API compatibility, state ownership, offline conflict resolution, OTA/runtime compatibility, security/privacy posture, or release/rollback risk.

Create a case study or incident learning note when a real project or production failure exposes a reusable architecture lesson. Always identify the checklist, pattern, anti-pattern, or implementation recipe that should change as a result.

## Link Strategy

- Prefer native Inkdrop links: `[Readable Title](inkdrop://note/<note-id-without-prefix>)`.
- Never invent note IDs. Search by exact title or scoped notebook first, then strip the returned `_id` prefix (`note:`) before building the URI.
- For batch imports, temporary `[[slug]]` links are acceptable during staging, but always plan a second pass to rewrite them after note IDs exist.
- Keep stable slug titles so search and link rewriting remain predictable.
- Link only strongly related notes, index/navigation notes, prerequisite concepts, ADRs, and implementation recipes. Avoid dense wiki-style over-linking.

## Inkdrop v6 Compatibility

- For Mermaid diagrams intended for Inkdrop v6, apply the shared rule pack at `agent-rules/tools/inkdrop-v6/mermaid.md` in the dotfiles repo before creating or updating a note.
- For internal note links, notebook/tag organization, statuses, and token-efficient MCP usage, apply `agent-rules/tools/inkdrop-v6/README.md` and only the referenced files needed for the task.
- If a note contains both Mermaid and internal links, validate both before writing: diagrams must render cleanly, and links must point to real note IDs.

## References

Read `references/inkdrop-conventions.md` when creating, importing, restructuring, or auditing notes. It contains title, template, tag, link, Markdown, and collaboration conventions.
Read `agent-rules/tools/inkdrop-v6/README.md` from the dotfiles repo when creating or editing Inkdrop v6 notes, Mermaid diagrams, indexes, note links, organization, or MCP workflows.
