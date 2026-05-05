# Inkdrop MCP Token Workflow

Use these rules to minimize token usage while keeping Inkdrop edits safe.

## Discovery

- Start with `search_notes` using qualifiers when possible:
  - `title:"VNPay - Security Architecture"`
  - `book:"VN Pay" status:active payment`
  - `tag:security status:active`
- Use `list_notes` with `bookId`, `limit`, `sort`, and `descending` for scoped discovery.
- Use `list_notebooks` only when the target notebook is unknown.
- Use `list_tags` only when assigning or auditing native tags.

## Reading

- Treat `search_notes` and `list_notes` results as previews because bodies are truncated.
- Read full bodies only for notes being edited, index notes being updated, and the top 1-3 related notes needed for context.

## Writing

- Never create a duplicate note without searching exact title and target notebook first.
- Use `patch_note` for small exact replacements after `read_note`.
- Use `update_note` for full replacements only when intentionally regenerating the whole note.
- Use `create_tag` only when an intended durable tag is missing.
- After creating or updating notes, report title, note ID, notebook, status, and important unresolved manual actions.
