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
ccc search --refresh <conceptual query>   # re-index changed files, then search
ccc search <conceptual query>
ccc status
ccc doctor
```

Use `--refresh` when the index may be stale (start of a session, after
significant changes); plain `ccc search` between searches with no code change.

If the project is not initialized:

- Fewer than about 200 tracked files (`git ls-files | wc -l`): do not index.
  Use `rg`, or `ccc grep` (structural grep, no index or daemon needed).
- Otherwise run `orc ccc init` from inside the repo, then retry. It initializes
  the git root, sets `max_file_size: 256KB` and runs `ccc index`. Without
  `orc`, do the same by hand: `ccc init`, add `max_file_size: 256KB` to
  `.cocoindex_code/settings.yml`, `ccc index`.

Useful search options:

```text
ccc search --path 'src/api/*' <query>
ccc search --lang typescript --lang markdown <query>
ccc search --offset 5 --limit 5 <query>
```

Use result file paths and line ranges to inspect surrounding source. Keep
paginating when the first result page is not enough.

## Agent-specific execution

- MCP: there is no global `cocoindex-code` server. `orc claude` and
  `orc codex` inject it per run, only when the git root is indexed and `ccc`
  is on `PATH` (`ORC_CCC=0` turns it off). Use `mcp__cocoindex-code__search`
  when it is listed; otherwise use the CLI.
- Codex: run `ccc` with its required elevated sandbox permission because the
  daemon uses `~/.cocoindex_code`.
- Claude Code: run the CLI through its native permission flow.
- Install with `uv tool install cocoindex-code`; `orc doctor` checks it and
  `orc update` upgrades it.

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
- Every project sets `max_file_size: 256KB` in `settings.yml` (`orc ccc init`
  adds it, and re-running it fixes a repo that lacks it) so lockfiles,
  generated parsers, and generated API schemas stay out of the index. Raise it
  only when real source files exceed it.
- After changing include/exclude patterns or `max_file_size`, preview with
  `ccc doctor`, then run `ccc index`; no reset or daemon restart is needed.
- If the machine runs hot, check `ccc daemon status` (loaded projects) and
  `ccc status` (chunk count). An unexpectedly large chunk count means the
  index is covering the wrong tree.
