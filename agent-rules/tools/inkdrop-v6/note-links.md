# Inkdrop v6 Note Link Rules

Use these rules when linking Inkdrop notes or maintaining index notes.

## Internal Links

- Preferred final form: `[Readable Title](inkdrop://note/<note-id-without-prefix>)`.
- Never invent note IDs. Search first with `title:"Exact Title"` or a scoped notebook/tag query.
- Strip the returned `_id` prefix (`note:`) before building the URI.
- Link text should match the target note title unless a shorter phrase improves readability.
- Link only index notes, prerequisites, parent concepts, ADRs, and strongly related implementation recipes.
- Do not mass-rewrite existing links unless explicitly requested.

## Two-Pass Linking

For batches of new notes:

1. Create notes without final internal links, or use temporary `[[stable-slug]]` placeholders.
2. Record each created note title and `_id`.
3. Replace placeholders with `inkdrop://note/<id>` links after all note IDs exist.
4. Re-read or search the updated notes to verify links and titles.
