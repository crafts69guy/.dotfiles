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

- Use `list_notebooks`, `list_notes`, `search_notes`, `read_note`, and `list_tags` before creating or updating notes.
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

## Link Strategy

- Prefer native Inkdrop links: `[Readable Title](inkdrop://note/<note-id>)`.
- For batch imports, temporary `[[slug]]` links are acceptable during staging, but plan a second pass to rewrite them after note IDs exist.
- Keep stable slug titles so search and link rewriting remain predictable.

## References

Read `references/inkdrop-conventions.md` when creating, importing, restructuring, or auditing notes. It contains title, template, tag, link, Markdown, and collaboration conventions.
