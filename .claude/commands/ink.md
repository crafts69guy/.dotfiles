# Inkdrop Journal

Create a journal entry in Inkdrop summarizing this session.

## Instructions

1. **Analyze the conversation** to extract:
   - Main topic/goal and what was achieved
   - Key decisions made (and reasoning)
   - Actions taken with outcomes
   - Insights or patterns discovered
   - Follow-up tasks identified

2. **Generate title** using format: `YYYY-MM-DD: <Main Topic>`
   - Example: `2026-01-17: Improve /ink command structure`

3. **List notebooks** using `mcp__inkdrop__list-notebooks` tool

4. **Ask user to select notebook** using AskUserQuestion with notebook options
   - Show top-level notebooks and commonly used ones
   - Include parent hierarchy for clarity (e.g., "Work > Antsomi")

5. **Create the note** using `mcp__inkdrop__create-note` with this structure:

   **Important**: Only include sections that have meaningful content. Skip empty sections.

   ```markdown
   ## Summary

   <2-3 sentences: what was the goal and what was achieved>

   ## What I Did

   - <Action 1> → <outcome>
   - <Action 2> → <outcome>

   > [!TIP]
   > <Key insight or useful pattern discovered - only if applicable>

   ## Decisions Made

   > [!NOTE]
   > <Important decision and why - only if decisions were made>

   ## Follow-ups

   - [ ] <Task to do later - only if there are follow-ups>

   ## References

   - `path/to/key/file.ext` - <context>

   ---

   _Claude Code session · YYYY-MM-DD_
   ```

   **Optional - Mermaid for Complex Flows**:
   When the session involves architecture or flow decisions, include:

   ```markdown
   ## Flow

   \`\`\`mermaid
   flowchart LR
   A[Step 1] --> B[Step 2]
   B --> C[Step 3]
   \`\`\`
   ```

6. **Confirm creation** by showing the note title and notebook name
