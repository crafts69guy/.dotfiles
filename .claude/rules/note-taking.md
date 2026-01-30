# Storing Plans in Inkdrop

Use the Inkdrop MCP server to persist plans and track execution progress.
Store notes in the notebook `Plan` (book:2iDoB4S9). Use the tool `list-notebooks` to find the notebook ID.

## When to Store

Save to Inkdrop when:

- The planner agent generates a plan
- Starting multi-step tasks that span multiple files
- Making architectural decisions

Skip for simple edits, or quick fixes.
The initial note status should be `none`.

## Note Format

1. Change the note status from `none` to `active` when work begins.
   See `@agents/planner.md` for detailed plan structure.
2. If the user specified a note that explains the task and context, add a link to that note at the top:

   ```markdown
   - Related note: [Note title](inkdrop://note/<noteId>)
   ```

   Note that the note id should be conveted to the Inkdrop URI like: `note:tFz4sfEw` -> `inkdrop://note/tFz4sfEw`

3. Store the generated plan as-is in the note body, with the following modifications:
   - Include the following information in the yaml frontmatter:
     - `description` - A brief summary of the plan
     - `projectDir` - The full path to the working directory
     - `gitBranch` - (optional) The git branch name if applicable
   - Remove the h1 heading at the beginning because the note already has a title.

   For example:

   ```yaml
   ---
   projectDir: /path/to/project
   description: Implementation plan for adding real-time notifications on market resolution.
   ---
   ```

4. Append a status section at the end:

   ```markdown
   ## Status

   - [ ] Step one
   - [ ] Step two
   - [ ] Step three
   ```

## Progress Updates

Update the note during execution as frequently as possible, as follows:

- Check off completed steps
- Annotate deviations: `- [x] Step two - used X instead due to Y`
- Note blockers: `- [ ] Step three (blocked: reason)`

## On Completion

Append an outcome section:

```markdown
## Outcome

Completed. Notes:

- <any deviations from plan>
- <follow-up tasks if any>
```

Also, change the note status to `completed`.

## Hygiene

- Change the note status to `dropped` for abandoned work
- Change the note status to `onHold` if the plan has not been acted on for 14 days

## Important

Do not erase or modify the original plan content.
Always preserve the full history of the planning and execution process.
If the plan has been altered while executing, just append updates rather than changing existing text.
