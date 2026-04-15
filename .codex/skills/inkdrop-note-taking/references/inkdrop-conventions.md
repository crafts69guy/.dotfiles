# Inkdrop Conventions

## Title and Body

- Inkdrop title: readable H1-style title, for example `Startup / Bootstrap Sequence` or `Auth System Design`.
- Do not use lowercase slug titles for final Inkdrop notes, for example avoid `startup-bootstrap-sequence`.
- Do not duplicate the Inkdrop title inside the body as a Markdown H1.
- Do not include a `Tags: #...` line in the body. Use Inkdrop native tags through the MCP `tags` field.
- New notes should use `active` status by default unless the user asks for another status or the note is explicitly archival/reference-only.

## Standard Note Template

```markdown
## What is this?

## Why it matters

## Core idea

## Design / Flow

## Rules / Best practices

## Trade-offs

## Related
```

Omit sections that add no value for small glossary or checklist notes.

## Note Types

- `concept`: design-level explanation or architecture concept.
- `implementation`: code-level detail, integration approach, or concrete implementation notes.
- `pattern`: reusable approach with constraints and trade-offs.
- `anti-pattern`: failure mode and safer alternative.
- `checklist`: actionable review or execution checklist.
- `example`: concrete flow, scenario, or applied design.
- `diagram`: Mermaid or text diagram note.
- `glossary`: term definition with related concepts.
- `index`: navigation note that links to other notes.

## Tag Taxonomy

Prefer lowercase tags.

Domain tags:

- `react-native`
- `architecture`
- `startup`
- `state`
- `navigation`
- `api`
- `auth`
- `observability`
- `release`

Type tags:

- `concept`
- `implementation`
- `pattern`
- `anti-pattern`
- `checklist`
- `example`
- `diagram`
- `glossary`
- `index`

Priority and quality tags:

- `critical`
- `production`
- `security`
- `research`

## Internal Links

Preferred final form:

```markdown
[Auth System Design](inkdrop://note/<note-id>)
```

Temporary import form:

```markdown
[[auth-system-design]]
```

Use a second pass after creating notes to replace temporary links with native Inkdrop links.

## Markdown Syntax

- Use fenced code blocks with language labels.
- Use `mermaid` fenced blocks only when Mermaid rendering is available in the user's Inkdrop setup.
- Use task lists for actionable checklists:
  `- [ ] Verify logout clears server-state cache`
- Use callouts sparingly:
  `> [!NOTE]`, `> [!WARNING]`, `> [!TIP]`
- Prefer short tables only when they improve scanning.

## Collaboration Rules

- Treat the user as a collaborator, not a passive requester.
- Ask the user to perform Inkdrop UI actions that MCP cannot do, then re-read the state before continuing.
- When acting as solution architect or senior developer, preserve design rationale, operational constraints, edge cases, and trade-offs.
- For technical research, separate verified facts, inferred design guidance, and open questions.
