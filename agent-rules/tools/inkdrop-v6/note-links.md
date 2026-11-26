# Inkdrop v6 Note Link Rules

Use these rules when linking Inkdrop notes or maintaining index notes.

## Internal Links

- Preferred final form: `[Readable Title](inkdrop://note/<note-id-without-prefix>)`.
- Never invent note IDs. Search first with `title:"Exact Title"` or a scoped notebook/tag query.
- Strip the returned `_id` prefix (`note:`) before building the URI.
- To point to a place inside a note, use an Inkdrop heading or line link. Use the heading fragment copied from the app or append a one-based line anchor such as `#L5` or `#L5-L8`. Use a whole-note link where later edits could shift the referenced lines.
- MCP can read a line range from a note link when the current tool supports it. Heading links open a section in Inkdrop. Locate that section in the full body when reading it through MCP.
- Link text should match the target note title unless a shorter phrase improves readability.
- Link only index notes, prerequisites, parent concepts, ADRs, and strongly related implementation recipes.
- Do not mass-rewrite existing links unless explicitly requested.

## Two-Pass Linking

For batches of new notes:

1. Create notes without final internal links, or use temporary `[[stable-slug]]` placeholders.
2. Record each created note title and `_id`.
3. Replace placeholders with `inkdrop://note/<id>` links after all note IDs exist.
4. Re-read or search the updated notes to verify links and titles.
