# CocoIndex Code (`ccc`)

Shared workflow for Codex and Claude Code.

## When to use it

Use `ccc` for semantic codebase search and index management when searching for
an implementation or behavior across the repository, exploring unfamiliar
architecture, or updating a stale index after significant changes.

Use `rg` for exact-name or small local lookups. Use `ccc` when the query is
about a concept, behavior, or relationship.

## Core workflow

Run from the project root:

```text
ccc search <conceptual query>
ccc index
ccc status
ccc doctor
```

If the project is not initialized, run `ccc init`, then `ccc index`, and retry
the original request. Refresh the index before searching when it may be stale.

Useful search options:

```text
ccc search --path 'src/api/*' <query>
ccc search --lang typescript --lang markdown <query>
ccc search --offset 5 --limit 5 <query>
```

Use result file paths and line ranges to inspect surrounding source. Keep
paginating when the first result page is not enough.

## Agent-specific execution

- Codex: run `ccc` with its required elevated sandbox permission because the
  daemon uses `~/.cocoindex_code`.
- Claude Code: prefer the `cocoindex-code` MCP server when available. If it is
  unavailable, use the installed `ccc` CLI and follow its native permission
  flow.

If a command fails, inspect the daemon log reported by `ccc doctor`.

## Index safety

Project settings live in `.cocoindex_code/settings.yml`; the database and
runtime files remain local and ignored. Do not commit embedding models,
databases, API keys, daemon state, or session history.

Do not assume hidden directories, generated artifacts, dependencies, or agent
metadata should be indexed without checking the project settings.

## Index scope

- One index per repository. Never run `ccc init` (or `ccc index`, which
  auto-inits) in a directory that holds several repos, such as
  `~/Developments/github.com/<owner>/`. `ccc` resolves the project by walking
  up to the nearest `.cocoindex_code/settings.yml`, so a parent index silently
  captures every uninitialized child repo and re-embeds all of them.
- Before `ccc init`, run `ccc status` from the repo root. If it reports a
  project root above the repo, stop and remove that stray settings file
  instead of searching.
- Small repos do not need an index; use `rg` there.
- Every project sets `max_file_size: 256KB` in `settings.yml` so lockfiles,
  generated parsers, and generated API schemas stay out of the index. Raise it
  only when real source files exceed it.
- After changing include/exclude patterns or `max_file_size`, preview with
  `ccc doctor`, then run `ccc index`; no reset or daemon restart is needed.
- If the machine runs hot, check `ccc daemon status` (loaded projects) and
  `ccc status` (chunk count). An unexpectedly large chunk count means the
  index is covering the wrong tree.
