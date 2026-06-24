# CodeDiff Solarized Osaka Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `codediff.nvim` to the LazyVim config with Git-focused keymaps and Solarized Osaka-matched highlights.

**Architecture:** Add one focused Lazy plugin spec under `.config/nvim/lua/plugins/`. The spec lazy-loads on `:CodeDiff`, defines `<leader>gd` keymaps, configures CodeDiff behavior, and applies Solarized Osaka highlight overrides on setup and colorscheme changes.

**Tech Stack:** Neovim Lua, LazyVim, lazy.nvim, `esmuellert/codediff.nvim`, `craftzdog/solarized-osaka.nvim`.

## Global Constraints

- Do not modify existing unrelated worktree changes.
- Do not commit changes unless explicitly requested.
- Keep configuration minimal and focused.
- Preserve current Git workflow with Snacks and Lazygit; CodeDiff is an additional review UI.
- Use Solarized Osaka palette for CodeDiff-specific highlights.

---

### Task 1: Add CodeDiff Plugin Spec

**Files:**
- Create: `.config/nvim/lua/plugins/codediff.lua`

**Interfaces:**
- Consumes: `solarized-osaka.colors`, `solarized-osaka.util.lighten`, `require("codediff").setup(opts)`.
- Produces: Lazy plugin spec for `esmuellert/codediff.nvim`, `apply_codediff_highlights()` local helper, `<leader>gd` keymaps.

- [ ] **Step 1: Create plugin spec**

Add `.config/nvim/lua/plugins/codediff.lua` with a single returned plugin table.

- [ ] **Step 2: Configure Lazy loading and keymaps**

Use `cmd = "CodeDiff"` and these mappings:

```lua
{ "<leader>gdd", "<cmd>CodeDiff<cr>", desc = "CodeDiff Status" }
{ "<leader>gdf", "<cmd>CodeDiff file HEAD<cr>", desc = "CodeDiff File" }
{ "<leader>gdh", "<cmd>CodeDiff history<cr>", desc = "CodeDiff History" }
{ "<leader>gdm", "<cmd>CodeDiff main...<cr>", desc = "CodeDiff Main" }
{ "<leader>gdi", "<cmd>CodeDiff --inline<cr>", desc = "CodeDiff Inline" }
{ "<leader>gds", "<cmd>CodeDiff --side-by-side<cr>", desc = "CodeDiff Side-by-side" }
```

- [ ] **Step 3: Configure CodeDiff behavior**

Use side-by-side default layout, left explorer width `40`, list mode, disabled inlay hints, no moved-code detection by default.

- [ ] **Step 4: Apply Solarized Osaka highlights**

Define CodeDiff line, char, move, status, explorer, and help highlight groups from the Solarized Osaka palette. Reapply through a `ColorScheme` autocmd.

- [ ] **Step 5: Verify syntax**

Run: `nvim --headless -u .config/nvim/init.lua +"lua dofile('.config/nvim/lua/plugins/codediff.lua')" +qa`

Expected: exits with status 0, or reports only plugin-manager/runtime issues unrelated to Lua syntax.

### Task 2: Review Worktree Diff

**Files:**
- Review: `.config/nvim/lua/plugins/codediff.lua`
- Review: `docs/superpowers/plans/2026-06-24-codediff-solarized-osaka.md`

**Interfaces:**
- Consumes: generated config and plan doc.
- Produces: confidence that only intended files changed.

- [ ] **Step 1: Check status**

Run: `git status --short`

Expected: new plan doc and CodeDiff config appear, existing unrelated changes remain untouched.

- [ ] **Step 2: Inspect diff**

Run: `git diff -- .config/nvim/lua/plugins/codediff.lua docs/superpowers/plans/2026-06-24-codediff-solarized-osaka.md`

Expected: diff contains only CodeDiff integration and plan documentation.
