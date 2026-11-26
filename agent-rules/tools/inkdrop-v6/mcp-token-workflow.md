# Inkdrop MCP Token Workflow

Use these rules to minimize token usage while keeping Inkdrop edits safe.

## Discovery

- Start with `search_notes` using qualifiers when possible:
  - `title:"VNPay - Security Architecture"`
  - `book:"VN Pay" status:active payment`
  - `tag:security status:active`
- Use `list_notes` with `bookId`, `limit`, `sort`, and `descending` for scoped discovery.
- When given a `book:…` ID, use it directly with `read_book` or `list_notes`.
- Use `list_notebooks` only when the target notebook is unknown.
- Use `list_tags` only when assigning or auditing native tags.

## Reading

- Treat `search_notes` and `list_notes` results as previews because bodies are truncated.
- For an `inkdrop://note/…#L5-L8` link, pass the full link to `read_note` if its schema supports line anchors. Otherwise read by `note:<id>` and select the requested Markdown lines from the body. See [note links](note-links.md).
- Read full bodies only for notes being edited, index notes being updated, and the top 1-3 related notes needed for context.

## Writing

- Never create a duplicate note without searching exact title and target notebook first.
- Read the current note before editing and pass its `_rev`. On a conflict or a failed exact match, re-read the note and reconcile the intended edit with the current body.
- Use `patch_note` for exact body edits. When the schema accepts `edits[]`, order the replacements as they should be applied. On older schemas, pass one top-level `old_string` and `new_string` pair per call and use the latest revision for each edit.
- Use `update_note` for metadata changes or intentional full-body replacements. Supply only the fields you mean to change. When the schema accepts `notes[]`, wrap each update in an item and check every result. Successful items are saved independently of failures. On older schemas, pass a single update at the top level.
- Use `create_tag` only when an intended durable tag is missing.
- After creating or updating notes, report title, note ID, notebook, status, and important unresolved manual actions.

## Templates

- For an existing note created from a template, use `read_note` with `includeTemplate: true` and follow `fill-out-template` when available. Read the full scaffold for in-place edits and preserve its source template link.
- For a new note from a named template, find it with `list_templates`, read its full body and apply its instructions and defaults to the user's request. Pass the template's note ID as `sourceTemplateId` to `create_note`, then verify the link with `read_note`.
- When a session cannot find or link templates through MCP, use a template note ID supplied by the user if the required tools accept it. If the session cannot save the template link, fill out an Inkdrop-created draft when available.

The current signatures and template features are documented in the [Inkdrop MCP tool reference](https://github.com/inkdropapp/mcp-server#tools).
